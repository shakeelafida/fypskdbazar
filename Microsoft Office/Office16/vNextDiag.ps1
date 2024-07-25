# vNextDiag.ps1
# This tool is intended to help see a snapshot of the state of Office licenses
# as well as some basic management of licenses.
#
# version 1.0.0

param ($action='list', $licenseId)

function PrintModePerPridFromRegistry
{
	Write-Host
	Write-Host "========== Mode per ProductReleaseId =========="

	$vNextRegkey = "HKCU:\SOFTWARE\Microsoft\Office\16.0\Common\Licensing\LicensingNext"
	$vNextPrids = Get-Item -Path $vNextRegkey -ErrorAction Ignore | Select-Object -ExpandProperty 'property' | Where-Object -FilterScript {$_.ToLower() -like "*retail" -or $_.ToLower() -like "*volume"}

	If ($vNextPrids -Eq $null)
	{
		Write-Host "No registry keys found."
		Return
	}

	$vNextPrids | ForEach `
	{
		$mode = (Get-ItemProperty -Path $vNextRegkey -Name $_).$_

		Switch ($mode)
		{
			2 { $mode = "vNext"; Break }
			3 { $mode = "Device"; Break }
			Default { $mode = "Legacy"; Break }
		}

		Write-Host $_ = $mode
	}
}

function PrintSharedComputerLicensing
{
	Write-Host
	Write-Host "========== Shared Computer Licensing =========="
    
    $scaRegKey = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
    $scaValue = Get-ItemProperty -Path $scaRegKey -ErrorAction Ignore | Select-Object -ExpandProperty "SharedComputerLicensing" -ErrorAction Ignore

	$scaRegKey2 = "HKLM:\SOFTWARE\Microsoft\Office\16.0\Common\Licensing"
    $scaValue2 = Get-ItemProperty -Path $scaRegKey2 -ErrorAction Ignore | Select-Object -ExpandProperty "SharedComputerLicensing" -ErrorAction Ignore

	$scaPolicyKey = "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\Licensing"
	$scaPolicyValue = Get-ItemProperty -Path $scaPolicyKey -ErrorAction Ignore | Select-Object -ExpandProperty "SharedComputerLicensing" -ErrorAction Ignore

	If ($scaValue -Eq $null -And $scaValue2 -Eq $null -And $scaPolicyValue -Eq $null)
	{
		Write-Host "No registry keys found."
		Return
	}

	$scaModeValue = $scaValue -Or $scaValue2 -Or $scaPolicyValue

    If ($scaModeValue -Eq 0)
    {
        $scaMode = "Disabled"
    }

    If ($scaModeValue -Eq 1)
    {
        $scaMode = "Enabled"
    }
	
	Write-Host "SharedComputerLicensing" = $scaMode
	
	$tokenFiles = $null
	$tokenPath = "${env:LOCALAPPDATA}\Microsoft\Office\16.0\Licensing"
	If (Test-Path $tokenPath)
	{
		$tokenFiles = Get-ChildItem -Path $tokenPath -Recurse -File -Filter "*authString*"
	}

	If ($tokenFiles.length -Eq 0)
	{
		Write-Host "No tokens found."
		Return
	}

	$tokenFiles | ForEach `
	{
		$tokenParts = (Get-Content -Encoding Unicode -Path $_.FullName).Split('_')
		$output = [PSCustomObject] `
			@{
				ACID = $tokenParts[0];
				User = $tokenParts[3]
				NotBefore = $tokenParts[4];
				NotAfter = $tokenParts[5];
			} | ConvertTo-Json

		Write-Host $output
	}
}

function PrintLicensesInformation
{
	Param(
		[ValidateSet("NUL", "Device")]
		[String]$mode
	)

	If ($mode -Eq "NUL")
	{
		$licensePath = "${env:LOCALAPPDATA}\Microsoft\Office\Licenses"
	}
	ElseIf ($mode -Eq "Device")
	{
		$licensePath = "${env:PROGRAMDATA}\Microsoft\Office\Licenses"
	}

	$licenseFiles = $null
	If (Test-Path $licensePath)
	{
		$licenseFiles = Get-ChildItem -Path $licensePath -Recurse -File
	}

	If ($licenseFiles.length -Eq 0)
	{
		Write-Host "No licenses found."
		Return
	}

	$licenseFiles | ForEach `
	{
		$license = (Get-Content -Encoding Unicode $_.FullName | ConvertFrom-Json).License
		$decodedLicense = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($license)) | ConvertFrom-Json

		$licenseType = $decodedLicense.LicenseType
		$userId = $decodedLicense.Metadata.UserId
		$identitiesRegkey = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Office\16.0\Common\Identity\Identities\${userId}*" -ErrorAction Ignore

		$email = $null
		If ($identitiesRegkey -Ne $null)
		{
			$email = $identitiesRegkey.EmailAddress
		}

		$licenseState = $null
		If ((Get-Date) -Gt (Get-Date $decodedLicense.MetaData.NotAfter))
		{
			$licenseState = "RFM"
		}
		ElseIf (($decodedLicense.ExpiresOn -Eq $null) -Or
			((Get-Date) -Lt (Get-Date $decodedLicense.ExpiresOn)))
		{
			$licenseState = "Licensed"
		}
		Else
		{
			$licenseState = "Grace"
		}

		if ($mode -Eq "NUL")
		{
			$output = [PSCustomObject] `
			@{
				Version = $_.Directory.Name
				Type = "User|${licenseType}";
				Product = $decodedLicense.ProductReleaseId;
				Acid = $decodedLicense.Acid;
				Email = $email;
				LicenseState = $licenseState;
				EntitlementStatus = $decodedLicense.Status;
				EntitlementExpiration = $decodedLicense.ExpiresOn;
				ReasonCode = $decodedLicense.ReasonCode;
				NotBefore = $decodedLicense.Metadata.NotBefore;
				NotAfter = $decodedLicense.Metadata.NotAfter;
				NextRenewal = $decodedLicense.Metadata.RenewAfter;
				TenantId = $decodedLicense.Metadata.TenantId;
                LicenseId = $decodedLicense.LicenseId;
			} | ConvertTo-Json
		}
		ElseIf ($mode -Eq "Device")
		{
			$output = [PSCustomObject] `
			@{
				Version = $_.Directory.Name
				Type = "Device|${licenseType}";
				Product = $decodedLicense.ProductReleaseId;
				Acid = $decodedLicense.Acid;
				DeviceId = $decodedLicense.Metadata.DeviceId;
				LicenseState = $licenseState;
				EntitlementStatus = $decodedLicense.Status;
				EntitlementExpiration = $decodedLicense.ExpiresOn;
				ReasonCode = $decodedLicense.ReasonCode;
				NotBefore = $decodedLicense.Metadata.NotBefore;
				NotAfter = $decodedLicense.Metadata.NotAfter;
				NextRenewal = $decodedLicense.Metadata.RenewAfter;
				TenantId = $decodedLicense.Metadata.TenantId;
                LicenseId = $decodedLicense.LicenseId;
			} | ConvertTo-Json
		}

		Write-Output $output
	}

}

function PrintLicensesInformationPerMode
{
	Write-Host
	Write-Host "========== vNext licenses found =========="
	PrintLicensesInformation -Mode "NUL"

	Write-Host
	Write-Host "========== Device licenses found =========="
	PrintLicensesInformation -Mode "Device"
}

function RemoveLicense
{
    Param( [String]$licenseToRemove )

	$licenseFiles = Get-ChildItem -Path "${env:LOCALAPPDATA}\Microsoft\Office\Licenses" -Recurse -File
    $licenseFiles += Get-ChildItem -Path "${env:PROGRAMDATA}\Microsoft\Office\Licenses" -Recurse -File

	If ($licenseFiles.length -Eq 0)
	{
		Write-Host "No licenses found."
		Return
	}

	$licenseFiles | ForEach `
	{
        $license = (Get-Content -Encoding Unicode $_.FullName | ConvertFrom-Json).License
		$decodedLicense = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($license)) | ConvertFrom-Json

        if ($decodedLicense.LicenseId -eq $licenseToRemove)
        {
            Remove-Item -Path $_.FullName
            Write-Host "Removed license with Id $($licenseToRemove)"
            exit
        }
    }

    Write-Host "Unable to find a license with Id $($licenseToRemove)"
}

# Main
if ($action -eq "list")
{
    PrintModePerPridFromRegistry
    PrintSharedComputerLicensing
    PrintLicensesInformationPerMode
}
elseif ($action -eq "remove")
{
    if ($licenseId -eq $null)
    {
        write-host "Please provide the LicenseId of the license to remove"
        exit
    }
    RemoveLicense -LicenseToRemove $licenseId
}
# SIG # Begin signature block
# MIIoSwYJKoZIhvcNAQcCoIIoPDCCKDgCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCYrg6juzAI+/ED
# jbL6pU5fLJVy++b9oK5IAtwzHNSeK6CCDYUwggYDMIID66ADAgECAhMzAAADri01
# UchTj1UdAAAAAAOuMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjMxMTE2MTkwODU5WhcNMjQxMTE0MTkwODU5WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQD0IPymNjfDEKg+YyE6SjDvJwKW1+pieqTjAY0CnOHZ1Nj5irGjNZPMlQ4HfxXG
# yAVCZcEWE4x2sZgam872R1s0+TAelOtbqFmoW4suJHAYoTHhkznNVKpscm5fZ899
# QnReZv5WtWwbD8HAFXbPPStW2JKCqPcZ54Y6wbuWV9bKtKPImqbkMcTejTgEAj82
# 6GQc6/Th66Koka8cUIvz59e/IP04DGrh9wkq2jIFvQ8EDegw1B4KyJTIs76+hmpV
# M5SwBZjRs3liOQrierkNVo11WuujB3kBf2CbPoP9MlOyyezqkMIbTRj4OHeKlamd
# WaSFhwHLJRIQpfc8sLwOSIBBAgMBAAGjggGCMIIBfjAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUhx/vdKmXhwc4WiWXbsf0I53h8T8w
# VAYDVR0RBE0wS6RJMEcxLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEWMBQGA1UEBRMNMjMwMDEyKzUwMTgzNjAfBgNVHSMEGDAW
# gBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIw
# MTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDEx
# XzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIB
# AGrJYDUS7s8o0yNprGXRXuAnRcHKxSjFmW4wclcUTYsQZkhnbMwthWM6cAYb/h2W
# 5GNKtlmj/y/CThe3y/o0EH2h+jwfU/9eJ0fK1ZO/2WD0xi777qU+a7l8KjMPdwjY
# 0tk9bYEGEZfYPRHy1AGPQVuZlG4i5ymJDsMrcIcqV8pxzsw/yk/O4y/nlOjHz4oV
# APU0br5t9tgD8E08GSDi3I6H57Ftod9w26h0MlQiOr10Xqhr5iPLS7SlQwj8HW37
# ybqsmjQpKhmWul6xiXSNGGm36GarHy4Q1egYlxhlUnk3ZKSr3QtWIo1GGL03hT57
# xzjL25fKiZQX/q+II8nuG5M0Qmjvl6Egltr4hZ3e3FQRzRHfLoNPq3ELpxbWdH8t
# Nuj0j/x9Crnfwbki8n57mJKI5JVWRWTSLmbTcDDLkTZlJLg9V1BIJwXGY3i2kR9i
# 5HsADL8YlW0gMWVSlKB1eiSlK6LmFi0rVH16dde+j5T/EaQtFz6qngN7d1lvO7uk
# 6rtX+MLKG4LDRsQgBTi6sIYiKntMjoYFHMPvI/OMUip5ljtLitVbkFGfagSqmbxK
# 7rJMhC8wiTzHanBg1Rrbff1niBbnFbbV4UDmYumjs1FIpFCazk6AADXxoKCo5TsO
# zSHqr9gHgGYQC2hMyX9MGLIpowYCURx3L7kUiGbOiMwaMIIHejCCBWKgAwIBAgIK
# YQ6Q0gAAAAAAAzANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlm
# aWNhdGUgQXV0aG9yaXR5IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEw
# OTA5WjB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYD
# VQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+la
# UKq4BjgaBEm6f8MMHt03a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc
# 6Whe0t+bU7IKLMOv2akrrnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4D
# dato88tt8zpcoRb0RrrgOGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+
# lD3v++MrWhAfTVYoonpy4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nk
# kDstrjNYxbc+/jLTswM9sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6
# A4aN91/w0FK/jJSHvMAhdCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmd
# X4jiJV3TIUs+UsS1Vz8kA/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL
# 5zmhD+kjSbwYuER8ReTBw3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zd
# sGbiwZeBe+3W7UvnSSmnEyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3
# T8HhhUSJxAlMxdSlQy90lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS
# 4NaIjAsCAwEAAaOCAe0wggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRI
# bmTlUAXTgqoXNzcitW2oynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAL
# BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBD
# uRQFTuHqp8cx0SOJNDBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jv
# c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3JsMF4GCCsGAQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3J0MIGfBgNVHSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEF
# BQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1h
# cnljcHMuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkA
# YwB5AF8AcwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn
# 8oalmOBUeRou09h0ZyKbC5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7
# v0epo/Np22O/IjWll11lhJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0b
# pdS1HXeUOeLpZMlEPXh6I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/
# KmtYSWMfCWluWpiW5IP0wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvy
# CInWH8MyGOLwxS3OW560STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBp
# mLJZiWhub6e3dMNABQamASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJi
# hsMdYzaXht/a8/jyFqGaJ+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYb
# BL7fQccOKO7eZS/sl/ahXJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbS
# oqKfenoi+kiVH6v7RyOA9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sL
# gOppO6/8MO0ETI7f33VtY5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtX
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGhwwghoYAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAAOuLTVRyFOPVR0AAAAA
# A64wDQYJYIZIAWUDBAIBBQCggcAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIIg0
# olNxrio8IwVWZNjQeXCcrCXNxVvcc+igfE+9WY9MMFQGCisGAQQBgjcCAQwxRjBE
# oCKAIABNAGkAYwByAG8AcwBvAGYAdAAgAE8AZgBmAGkAYwBloR6AHGh0dHA6Ly9v
# ZmZpY2UubWljcm9zb2Z0LmNvbSAwDQYJKoZIhvcNAQEBBQAEggEA3Pa/2AgQJxr5
# KWShnIXUtyojB6GeLrhbT/Cw5o2BuLlrECAJao1CwJP8MP3oel8RJr/Cm+GIQNJm
# aZKhUHibkpKZDVeCcvhINT8OagMAcrfpFQHsmjpJPXpLzTMOpzLlRpqFTuEHIki4
# xXvHfCrxXKNgVXg9GAeGOzGlOSDvvdb79cxF/UrpiD/UJja9iyN2Y+Hwq4LatAsQ
# gSJ9uKfrD1A3nBd7arue4GqCygYm15STSOihW+jz0N6PbcHpxlnUdwE6ofUw2YNK
# pzFVTRtZr/w4tS3rEQXNeKfCN9PHRnKoiTujpWgXfYrN6uT1zmi4hLxm3Y8XhFgv
# 6fDXUhyu+aGCF5QwgheQBgorBgEEAYI3AwMBMYIXgDCCF3wGCSqGSIb3DQEHAqCC
# F20wghdpAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsqhkiG9w0BCRABBKCCAUEE
# ggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFlAwQCAQUABCAjKTLvEEbe
# N8IGSxe0dGeI4l3yQFwade/tQs94c3edWgIGZkZG4wIeGBMyMDI0MDYxOTE5MDQx
# Ni40NzJaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046RjAwMi0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WgghHqMIIHIDCCBQigAwIB
# AgITMwAAAfI+MtdkrHCRlAABAAAB8jANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQg
# VGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yMzEyMDYxODQ1NThaFw0yNTAzMDUxODQ1
# NThaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYD
# VQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hp
# ZWxkIFRTUyBFU046RjAwMi0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBU
# aW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQC85fPLFwppYgxwYxkSEeYvQBtnYJTtKKj2FKxzHx0fgV6XgIIrmCWmpKl9IOzv
# OfJ/k6iP0RnoRo5F89Ad29edzGdlWbCj1Qyx5HUHNY8yu9ElJOmdgeuNvTK4RW4w
# u9iB5/z2SeCuYqyX/v8z6Ppv29h1ttNWsSc/KPOeuhzSAXqkA265BSFT5kykxvzB
# 0LxoxS6oWoXWK6wx172NRJRYcINfXDhURvUfD70jioE92rW/OgjcOKxZkfQxLlwa
# FSrSnGs7XhMrp9TsUgmwsycTEOBdGVmf1HCD7WOaz5EEcQyIS2BpRYYwsPMbB63u
# HiJ158qNh1SJXuoL5wGDu/bZUzN+BzcLj96ixC7wJGQMBixWH9d++V8bl10RYdXD
# ZlljRAvS6iFwNzrahu4DrYb7b8M7vvwhEL0xCOvb7WFMsstscXfkdE5g+NSacphg
# FfcoftQ5qPD2PNVmrG38DmHDoYhgj9uqPLP7vnoXf7j6+LW8Von158D0Wrmk7Cum
# ucQTiHRyepEaVDnnA2GkiJoeh/r3fShL6CHgPoTB7oYU/d6JOncRioDYqqRfV2wl
# pKVO8b+VYHL8hn11JRFx6p69mL8BRtSZ6dG/GFEVE+fVmgxYfICUrpghyQlETJPI
# TEBS15IsaUuW0GvXlLSofGf2t5DAoDkuKCbC+3VdPmlYVQIDAQABo4IBSTCCAUUw
# HQYDVR0OBBYEFJVbhwAm6tAxBM5cH8Bg0+Y64oZ5MB8GA1UdIwQYMBaAFJ+nFV0A
# XmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly93d3cubWlj
# cm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQ
# Q0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4wXAYIKwYBBQUHMAKGUGh0
# dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIw
# VGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwGA1UdEwEB/wQCMAAwFgYD
# VR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQDAgeAMA0GCSqGSIb3DQEB
# CwUAA4ICAQA9S6eO4HsfB00XpOgPabcN3QZeyipgilcQSDZ8g6VCv9FVHzdSq9Xp
# AsljZSKNWSClhJEz5Oo3Um/taPnobF+8CkAdkcLQhLdkShfr91kzy9vDPrOmlCA2
# FQ9jVhFaat2QM33z1p+GCP5tuvirFaUWzUWVDFOpo/O5zDpzoPYtTr0cFg3uXaRL
# T54UQ3Y4uPYXqn6wunZtUQRMiJMzxpUlvdfWGUtCvnW3eDBikDkix1XE98VcYIz2
# +5fdcvrHVeUarGXy4LRtwzmwpsCtUh7tR6whCrVYkb6FudBdWM7TVvji7pGgfjes
# gnASaD/ChLux66PGwaIaF+xLzk0bNxsAj0uhd6QdWr6TT39m/SNZ1/UXU7kzEod0
# vAY3mIn8X5A4I+9/e1nBNpURJ6YiDKQd5YVgxsuZCWv4Qwb0mXhHIe9CubfSqZjv
# Dawf2I229N3LstDJUSr1vGFB8iQ5W8ZLM5PwT8vtsKEBwHEYmwsuWmsxkimIF5BQ
# bSzg9wz1O6jdWTxGG0OUt1cXWOMJUJzyEH4WSKZHOx53qcAvD9h0U6jEF2fuBjtJ
# /QDrWbb4urvAfrvqNn9lH7gVPplqNPDIvQ8DkZ3lvbQsYqlz617e76ga7SY0w71+
# QP165CPdzUY36et2Sm4pvspEK8hllq3IYcyX0v897+X9YeecM1Pb1jCCB3EwggVZ
# oAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZIhvcNAQELBQAwgYgxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jv
# c29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDEwMB4XDTIxMDkzMDE4
# MjIyNVoXDTMwMDkzMDE4MzIyNVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDk4aZM57RyIQt5osvX
# JHm9DtWC0/3unAcH0qlsTnXIyjVX9gF/bErg4r25PhdgM/9cT8dm95VTcVrifkpa
# /rg2Z4VGIwy1jRPPdzLAEBjoYH1qUoNEt6aORmsHFPPFdvWGUNzBRMhxXFExN6AK
# OG6N7dcP2CZTfDlhAnrEqv1yaa8dq6z2Nr41JmTamDu6GnszrYBbfowQHJ1S/rbo
# YiXcag/PXfT+jlPP1uyFVk3v3byNpOORj7I5LFGc6XBpDco2LXCOMcg1KL3jtIck
# w+DJj361VI/c+gVVmG1oO5pGve2krnopN6zL64NF50ZuyjLVwIYwXE8s4mKyzbni
# jYjklqwBSru+cakXW2dg3viSkR4dPf0gz3N9QZpGdc3EXzTdEonW/aUgfX782Z5F
# 37ZyL9t9X4C626p+Nuw2TPYrbqgSUei/BQOj0XOmTTd0lBw0gg/wEPK3Rxjtp+iZ
# fD9M269ewvPV2HM9Q07BMzlMjgK8QmguEOqEUUbi0b1qGFphAXPKZ6Je1yh2AuIz
# GHLXpyDwwvoSCtdjbwzJNmSLW6CmgyFdXzB0kZSU2LlQ+QuJYfM2BjUYhEfb3BvR
# /bLUHMVr9lxSUV0S2yW6r1AFemzFER1y7435UsSFF5PAPBXbGjfHCBUYP3irRbb1
# Hode2o+eFnJpxq57t7c+auIurQIDAQABo4IB3TCCAdkwEgYJKwYBBAGCNxUBBAUC
# AwEAATAjBgkrBgEEAYI3FQIEFgQUKqdS/mTEmr6CkTxGNSnPEP8vBO4wHQYDVR0O
# BBYEFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMFwGA1UdIARVMFMwUQYMKwYBBAGCN0yD
# fQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lv
# cHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAKBggrBgEFBQcDCDAZBgkr
# BgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUw
# AwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8ETzBN
# MEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0
# cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoG
# CCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01p
# Y1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAnVV9
# /Cqt4SwfZwExJFvhnnJL/Klv6lwUtj5OR2R4sQaTlz0xM7U518JxNj/aZGx80HU5
# bbsPMeTCj/ts0aGUGCLu6WZnOlNN3Zi6th542DYunKmCVgADsAW+iehp4LoJ7nvf
# am++Kctu2D9IdQHZGN5tggz1bSNU5HhTdSRXud2f8449xvNo32X2pFaq95W2KFUn
# 0CS9QKC/GbYSEhFdPSfgQJY4rPf5KYnDvBewVIVCs/wMnosZiefwC2qBwoEZQhlS
# dYo2wh3DYXMuLGt7bj8sCXgU6ZGyqVvfSaN0DLzskYDSPeZKPmY7T7uG+jIa2Zb0
# j/aRAfbOxnT99kxybxCrdTDFNLB62FD+CljdQDzHVG2dY3RILLFORy3BFARxv2T5
# JL5zbcqOCb2zAVdJVGTZc9d/HltEAY5aGZFrDZ+kKNxnGSgkujhLmm77IVRrakUR
# R6nxt67I6IleT53S0Ex2tVdUCbFpAUR+fKFhbHP+CrvsQWY9af3LwUFJfn6Tvsv4
# O+S3Fb+0zj6lMVGEvL8CwYKiexcdFYmNcP7ntdAoGokLjzbaukz5m/8K6TT4JDVn
# K+ANuOaMmdbhIurwJ0I9JZTmdHRbatGePu1+oDEzfbzL6Xu/OHBE0ZDxyKs6ijoI
# Yn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggNNMIICNQIBATCB+aGB0aSB
# zjCByzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UE
# CxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEnMCUGA1UECxMeblNoaWVs
# ZCBUU1MgRVNOOkYwMDItMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQBri943cFLH2TfQEfB05SLI
# Cg74CKCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqG
# SIb3DQEBCwUAAgUA6h2VvzAiGA8yMDI0MDYxOTE3MzcwM1oYDzIwMjQwNjIwMTcz
# NzAzWjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDqHZW/AgEAMAcCAQACAix8MAcC
# AQACAhMeMAoCBQDqHuc/AgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkK
# AwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQELBQADggEBAFEk
# 2skXatkuh9E5A/0KflMsOgZu6VRmBDRI96+rxUUNdVahCdu3qdaULbJylOAjVz2G
# DyBzoR+obQDWBN++EQYdA475rBmw+lNljEDZp90OAZMTInstDX+7xZgB+LJ9flm4
# zqE/n03155qYy9zhWIzraNyDyMQypE1g/5lzzr9Gcm6eO8Aeb7SKN9pFIazbF6rs
# DenUdj44GjmgtsUmWKkE+HXBSrvfJ7t/7HgJ1CBDmuONAcJOSSFhWVd3r1bgNo7Z
# 9flJsxa1ypVkiqZhXsCWh3rJNc33pD/ItNKegMnIsTYoSBQodW/2ltYH1Qx4gPvS
# qUtbXY8ZlpdTqZPqVGgxggQNMIIECQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEG
# A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFt
# cCBQQ0EgMjAxMAITMwAAAfI+MtdkrHCRlAABAAAB8jANBglghkgBZQMEAgEFAKCC
# AUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCAr
# B9I+GmhGvPeQz4AMjKV/h8VGE4eNeLZr879sgITFkzCB+gYLKoZIhvcNAQkQAi8x
# geowgecwgeQwgb0EIPjaPh0uMVJc04+Y4Ru5BUUbHE4suZ6nRHSUu0XXSkNEMIGY
# MIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQG
# A1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAHyPjLXZKxw
# kZQAAQAAAfIwIgQgsGZ7Oiwru33tmw6++kZna2lsPPil7W4SmkW96KdlVtwwDQYJ
# KoZIhvcNAQELBQAEggIAntQpqO7DDOHxfz1avvl3xOE/rUlc3AJypaJVGZt8LDT+
# PDbG8Qd0s/hoshMFmUDIt886zBcINXDOfXXG7CcQ9olfkd9aUSVDQcni87SUbuTV
# nqYFmqNVmo405+Oypc8y0DCi6a5MLveCK95k/vifXpgzT9np2E0ftFZgvXgHwPVZ
# UWJ+UemQYPQ7yf/Lfu8BQrkrxaC14Ap6bCJjjFxAZIeL1E9+HHVylnXWRDo+3VOC
# MpkYMdkZ1cxaCLVF7CQ7G4dRnkd9IyZ940l9a1IUFnodM4c06/jtFC4JlJekedj7
# lVUJac6d8RAxuGmlaWHDih1lpN0toJdV1+KAOPO7PvTg068LlByleEe2q0qwqirT
# jwRMKb+v9eTh5Yk/SRBwr7Lhz2RN8E92Vha1JgpSC3AH1dRnAbtXk8d0gnf5040W
# j/sl/PmVLeCClbnfL8NZgDuJEq4B/mAXoHEmsl+cOsWBL2AzYSFdwYYy31eFbOgY
# H52WpTfli0iWSqf1Q7fLWECUUh2a7iU6RZF+tkw7YV9k2f/SCwoWJgRbRtGTHer0
# ql5zWVhExxRykXgoq1Ks18MfKcHSpc1LBTUuF7syJzD2GETC0ikpCRGQwUjeQpvX
# d9LE+4Ss4eGt31sI9Dx1+P1u8kXLDmcK8AR7G+ASEPFcFgMRVEucyiY4THsmlfE=
# SIG # End signature block

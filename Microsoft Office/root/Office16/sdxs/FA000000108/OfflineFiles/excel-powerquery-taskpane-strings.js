/* tslint:disable */ var ExcelPowerqueryTaskpaneStrings = { "OverflowWellLabel": "More Options", "SpinnerLoadingLabel": "Loading...", "MoveToPageSelectGroup": "Select a group", "MoveToConflictNamesErrorMessage": "Group {0} cannot be moved to group {1} because there is already a group named {0}.", "QueriesCountTaskpaneHeadline": "{0} queries", "OneQueryTaskpaneHeadline": "1 query", "ConnectionsCountTaskpaneHeadline": "{0} connections", "OneConnectionTaskpaneHeadline": "1 connection", "MoveQueryToGroupOption": "Move to group", "CreateNewGroupOption": "New group", "UngroupOption": "Ungroup", "DeleteGroupOption": "Delete group", "DeleteQueryOption": "Delete", "RenameQueryOption": "Rename", "EditQueryOption": "Edit", "DuplicateQueryOption": "Duplicate", "RenameGroupOption": "Rename", "ExpandAllOption": "Expand all", "CollapseAllOption": "Collapse all", "MoveToTopLevelOption": "Move to top level", "MoveUpOption": "Move up", "MoveDownOption": "Move down", "PropertiesOption": "Properties", "ExportConnectionFileOption": "Export Connection Files...", "QueriesTaskpaneAriaLabel": "Queries Pane", "QueryAriaLabel": "Query {0} of {1}", "ConnectionAriaLabel": "Connection {0} of {1}", "QueryLastRefreshed": "Last refreshed {0}", "QueryRowsLoaded": "{0} rows loaded.", "QueryRowLoaded": "1 row loaded.", "LoadedToConnectionOnly": "Connection only", "LoadedTo": "Loaded to {0}", "LoadedToDataModel": "Loaded to {0} and Data Model", "LoadedToTable": "worksheet", "LoadedToPivotTable": "Pivot Table", "LoadedToPivotChart": "Pivot Chart", "DownloadDidNotComplete": "Download did not complete", "DownloadFailed": "Download failed", "LoadToWorksheetFailed": "Load to worksheet failed", "LoadToDataModelFailed": "Load to Data Model failed", "DataModel": "Data Model", "GroupNameInputLabel": "Group name", "QueryNameInputLabel": "Query name", "PropertiesDescriptionInputLabel": "Description", "PropertiesDescriptionInputPlaceHolder": "Enter a description ...", "SaveButton": "Save", "CancelButton": "Cancel", "NewGroupContextMenuButton": "New Group...", "EmptyGroupNameErrorMessage": "Query group name cannot be blank or consist only of whitespaces.", "GroupNameContainsBackslashErrorMessage": "Query group name cannot contain the following characters \\.", "GroupNameConflictsErrorMessage": "The name '{0}' conflicts with a peer query group.", "QueryNameEmptyErrorMessage": "Query names cannot be blank or consist only of whitespace.", "QueryNameWithInvalidCharactersErrorMessage": "Query names cannot contain periods or quotation marks. (. \")", "QueryNameTooLongErrorMessage": "Query names are limited to {0} characters.", "QueryNameAlreadyExistsErrorMessage": "A query named '{0}' already exists.", "OneError": "1 error.", "ErrorsCount": "{0} errors.", "Refresh": "Refresh", "RefreshAll": "Refresh All", "Cancel": "Cancel", "QueriesTaskpaneKeytip": "O", "OtherQueriesGroupName": "Other Queries", "QueriesSearchPlaceholder": "Search", "QueriesSearchNoQueriesFound": "No queries found", "QueriesSearchNumQueriesFound": "{0} queries found", "QueriesSearchOneQueryFound": "1 query found", "ConnectionsTaskPaneTab": "Connections", "QueriesTaskPaneTab": "Queries", "ConnectionsTaskpaneAriaLabel": "Connections Pane", "QueryDeleting": "Deleting query...", "QueryReorder": "{0} moved to position {1}.", "QueryReorderOutsideGroup": "{0} moved to {1} to position {2}.", "ClearAllPermissions": "Clear all Permissions", "Usage": "Usage", "EnableBackgroundRefresh": "Enable background refresh", "RefreshEvery": "Refresh every", "Minutes": "minutes", "RefreshDataOnopen": "Refresh data when opening the file", "RemoveDataFromWorkbook": "Remove data from the external data range before saving the workbook", "RefreshOnRefreshAll": "Refresh this connection on Refresh All", "EnableFastDataLoad": "Enable fast data load", "PasteOption": "Paste", "CannotEditQueryLoadedToDataModel": "You cannot edit a query that has been loaded to the Data Model while using Excel for Web.", "CannotEditQueryWhileRefreshing": "You cannot edit a query while it is being refreshed.", "CopyOption": "Copy", "ManageConnectionsNoConnection": "No data sources found." };
/* tslint:disable */ var ExcelPowerqueryTaskpaneStringsEnum;
/* tslint:disable */ var ExcelPowerqueryTaskpaneStringsArray;
if (!ExcelPowerqueryTaskpaneStringsEnum) {
    if (typeof window !== 'undefined' && (window.g_NewStringsInfra === true || window.g_NewStringsInfra === "True")) {
        ExcelPowerqueryTaskpaneStringsEnum = Object.keys(ExcelPowerqueryTaskpaneStrings).reduce(function (acc, key, index) {
            acc[key] = index;
            return acc;
        }, {});
        if (!ExcelPowerqueryTaskpaneStringsArray) {
            ExcelPowerqueryTaskpaneStringsArray = Object.values(ExcelPowerqueryTaskpaneStrings);
        }
    }
    else {
        ExcelPowerqueryTaskpaneStringsEnum = ExcelPowerqueryTaskpaneStrings;
    }
}
var ExcelPowerqueryTaskpaneStringsManager = {
    ExcelPowerqueryTaskpaneStringsArray: ExcelPowerqueryTaskpaneStringsArray,
    get: function (x) {
        if (typeof window !== 'undefined' && (window.g_NewStringsInfra === true || window.g_NewStringsInfra === "True")) {
            return ExcelPowerqueryTaskpaneStringsArray[x];
        }
        else {
            return x;
        }
    }
};

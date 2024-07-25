/* tslint:disable */ var UxppStrings = { "SpinnerLoadingLabel": "Loading...", "RaiseTestEventLabel": "Raise a test event" };
/* tslint:disable */ var UxppStringsEnum;
/* tslint:disable */ var UxppStringsArray;
if (!UxppStringsEnum) {
    if (typeof window !== 'undefined' && (window.g_NewStringsInfra === true || window.g_NewStringsInfra === "True")) {
        UxppStringsEnum = Object.keys(UxppStrings).reduce(function (acc, key, index) {
            acc[key] = index;
            return acc;
        }, {});
        if (!UxppStringsArray) {
            UxppStringsArray = Object.values(UxppStrings);
        }
    }
    else {
        UxppStringsEnum = UxppStrings;
    }
}
var UxppStringsManager = {
    UxppStringsArray: UxppStringsArray,
    get: function (x) {
        if (typeof window !== 'undefined' && (window.g_NewStringsInfra === true || window.g_NewStringsInfra === "True")) {
            return UxppStringsArray[x];
        }
        else {
            return x;
        }
    }
};

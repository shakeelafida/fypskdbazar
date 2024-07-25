/* tslint:disable */ var FriendlyDatesStrings = { "JustNow": "Just now", "MinutesAgo": "{mins, plural, one {1 minute ago} other {# minutes ago}}", "MinAgo": "{0} min ago", "MinAgoShort": "{mins, plural, one {1 min ago} other {# mins ago}}", "HoursAgo": "{hours, plural, one {1 hour ago} other {# hours ago}}", "HrAgo": "{0} hr ago", "HrAgoShort": "{hrs, plural, one {1 hr ago} other {# hrs ago}}", "YesterdayAt": "Yesterday at {0}", "DateTimeCombo": "{0} at {1}", "YesterdayWithTime": "Yesterday, {0}", "DateTimeComboNoAt": "{0}, {1}" };
/* tslint:disable */ var FriendlyDatesStringsEnum;
/* tslint:disable */ var FriendlyDatesStringsArray;
if (!FriendlyDatesStringsEnum) {
    if (typeof window !== 'undefined' && (window.g_NewStringsInfra === true || window.g_NewStringsInfra === "True")) {
        FriendlyDatesStringsEnum = Object.keys(FriendlyDatesStrings).reduce(function (acc, key, index) {
            acc[key] = index;
            return acc;
        }, {});
        if (!FriendlyDatesStringsArray) {
            FriendlyDatesStringsArray = Object.values(FriendlyDatesStrings);
        }
    }
    else {
        FriendlyDatesStringsEnum = FriendlyDatesStrings;
    }
}
var FriendlyDatesStringsManager = {
    FriendlyDatesStringsArray: FriendlyDatesStringsArray,
    get: function (x) {
        if (typeof window !== 'undefined' && (window.g_NewStringsInfra === true || window.g_NewStringsInfra === "True")) {
            return FriendlyDatesStringsArray[x];
        }
        else {
            return x;
        }
    }
};

# Custom Locale Data

This folder is used to store custom locale data. These custom locale data are
not yet provided by [Unicode Common Locale Data Repository](http://cldr.unicode.org/development/new-cldr-developers)
and hence not provided in [react-intl/locale-data/*](https://github.com/yahoo/react-intl).

The locale data should support [Locale Data APIs](https://github.com/yahoo/react-intl/wiki/API#locale-data-apis)
of the react-intl library.

It is recommended to start your custom locale data from this sample English
locale data:

```javascript
/*eslint eqeqeq: "off"*/
/*eslint no-nested-ternary: "off"*/

export default [
  {
    locale: "en",
    pluralRuleFunction: function(e, a) {
      var n = String(e).split("."),
        l = !n[1],
        o = Number(n[0]) == e,
        t = o && n[0].slice(-1),
        r = o && n[0].slice(-2);
      return a ? 1 == t && 11 != r ? "one" : 2 == t && 12 != r ? "two" : 3 == t && 13 != r ? "few" : "other" : 1 == e && l ? "one" : "other"
    },
    fields: {
      year: {
        displayName: "year",
        relative: {
          0: "this year",
          1: "next year",
          "-1": "last year"
        },
        relativeTime: {
          future: {
            one: "in {0} year",
            other: "in {0} years"
          },
          past: {
            one: "{0} year ago",
            other: "{0} years ago"
          }
        }
      },
      month: {
        displayName: "month",
        relative: {
          0: "this month",
          1: "next month",
          "-1": "last month"
        },
        relativeTime: {
          future: {
            one: "in {0} month",
            other: "in {0} months"
          },
          past: {
            one: "{0} month ago",
            other: "{0} months ago"
          }
        }
      },
      day: {
        displayName: "day",
        relative: {
          0: "today",
          1: "tomorrow",
          "-1": "yesterday"
        },
        relativeTime: {
          future: {
            one: "in {0} day",
            other: "in {0} days"
          },
          past: {
            one: "{0} day ago",
            other: "{0} days ago"
          }
        }
      },
      hour: {
        displayName: "hour",
        relativeTime: {
          future: {
            one: "in {0} hour",
            other: "in {0} hours"
          },
          past: {
            one: "{0} hour ago",
            other: "{0} hours ago"
          }
        }
      },
      minute: {
        displayName: "minute",
        relativeTime: {
          future: {
            one: "in {0} minute",
            other: "in {0} minutes"
          },
          past: {
            one: "{0} minute ago",
            other: "{0} minutes ago"
          }
        }
      },
      second: {
        displayName: "second",
        relative: {
          0: "now"
        },
        relativeTime: {
          future: {
            one: "in {0} second",
            other: "in {0} seconds"
          },
          past: {
            one: "{0} second ago",
            other: "{0} seconds ago"
          }
        }
      }
    }
  }
]

```

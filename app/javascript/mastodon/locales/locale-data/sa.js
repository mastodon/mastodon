/*eslint eqeqeq: "off"*/
/*eslint no-nested-ternary: "off"*/
/*eslint quotes: "off"*/
/*eslint comma-dangle: "off"*/

const rules = [
  {
    locale: "sa",
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
            other: "+{0} y"
          },
          past: {
            other: "-{0} y"
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
            other: "+{0} m"
          },
          past: {
            other: "-{0} m"
          }
        }
      },
      day: {
        displayName: "day",
        relative: {
          0: "अद्य",
          1: "श्वः",
          "-1": "गतदिनम्"
        },
        relativeTime: {
          future: {
            other: "+{0} d"
          },
          past: {
            other: "-{0} d"
          }
        }
      },
      hour: {
        displayName: "hour",
        relativeTime: {
          future: {
            other: "+{0} h"
          },
          past: {
            other: "-{0} h"
          }
        }
      },
      minute: {
        displayName: "minute",
        relativeTime: {
          future: {
            other: "+{0} min"
          },
          past: {
            other: "-{0} min"
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
            other: "+{0} s"
          },
          past: {
            other: "-{0} s"
          }
        }
      }
    }
  }
];

export default rules;

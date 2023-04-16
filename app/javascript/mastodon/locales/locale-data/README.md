# Custom Locale Data

This folder is used to store custom locale data. These custom locale data are
not yet provided by [Unicode Common Locale Data Repository](http://cldr.unicode.org/development/new-cldr-developers)
and hence not provided in [react-intl/locale-data/\*](https://github.com/yahoo/react-intl).

The locale data should support [Locale Data APIs](https://github.com/yahoo/react-intl/wiki/API#locale-data-apis)
of the react-intl library.

It is recommended to start your custom locale data from this sample English
locale data ([\*](#plural-rules)):

```javascript
/*eslint eqeqeq: "off"*/
/*eslint no-nested-ternary: "off"*/

export default [
  {
    locale: 'en',
    pluralRuleFunction: function (e, a) {
      var n = String(e).split('.'),
        l = !n[1],
        o = Number(n[0]) == e,
        t = o && n[0].slice(-1),
        r = o && n[0].slice(-2);
      return a
        ? 1 == t && 11 != r
          ? 'one'
          : 2 == t && 12 != r
          ? 'two'
          : 3 == t && 13 != r
          ? 'few'
          : 'other'
        : 1 == e && l
        ? 'one'
        : 'other';
    },
    fields: {
      year: {
        displayName: 'year',
        relative: {
          0: 'this year',
          1: 'next year',
          '-1': 'last year',
        },
        relativeTime: {
          future: {
            one: 'in {0} year',
            other: 'in {0} years',
          },
          past: {
            one: '{0} year ago',
            other: '{0} years ago',
          },
        },
      },
      month: {
        displayName: 'month',
        relative: {
          0: 'this month',
          1: 'next month',
          '-1': 'last month',
        },
        relativeTime: {
          future: {
            one: 'in {0} month',
            other: 'in {0} months',
          },
          past: {
            one: '{0} month ago',
            other: '{0} months ago',
          },
        },
      },
      day: {
        displayName: 'day',
        relative: {
          0: 'today',
          1: 'tomorrow',
          '-1': 'yesterday',
        },
        relativeTime: {
          future: {
            one: 'in {0} day',
            other: 'in {0} days',
          },
          past: {
            one: '{0} day ago',
            other: '{0} days ago',
          },
        },
      },
      hour: {
        displayName: 'hour',
        relativeTime: {
          future: {
            one: 'in {0} hour',
            other: 'in {0} hours',
          },
          past: {
            one: '{0} hour ago',
            other: '{0} hours ago',
          },
        },
      },
      minute: {
        displayName: 'minute',
        relativeTime: {
          future: {
            one: 'in {0} minute',
            other: 'in {0} minutes',
          },
          past: {
            one: '{0} minute ago',
            other: '{0} minutes ago',
          },
        },
      },
      second: {
        displayName: 'second',
        relative: {
          0: 'now',
        },
        relativeTime: {
          future: {
            one: 'in {0} second',
            other: 'in {0} seconds',
          },
          past: {
            one: '{0} second ago',
            other: '{0} seconds ago',
          },
        },
      },
    },
  },
];
```

## Notes

### Plural Rules

The function `pluralRuleFunction()` should return the key to proper string of
a plural form(s). The purpose of the function is to provide key of translate
strings of correct plural form according. The different forms are described in
[CLDR's Plural Rules][cldr-plural-rules],

[cldr-plural-rules]: http://cldr.unicode.org/index/cldr-spec/plural-rules

#### Quick Overview on CLDR Rules

Let's take English as an example.

When you describe a number, you can be either describe it as:

- Cardinals: 1st, 2nd, 3rd ... 11th, 12th ... 21st, 22nd, 23nd ....
- Ordinals: 1, 2, 3 ...

In any of these cases, the nouns will reflect the number with singular or plural
form. For example:

- in 0 days
- in 1 day
- in 2 days

The `pluralRuleFunction` receives 2 parameters:

- `e`: a string representation of the number. Such as, "`1`", "`2`", "`2.1`".
- `a`: `true` if this is "cardinal" type of description. `false` for ordinal and other case.

#### How you should write `pluralRuleFunction`

The first rule to write pluralRuleFunction is never translate the output string
into your language. [Plural Rules][cldr-plural-rules] specified you should use
these as the return values:

- "`zero`"
- "`one`" (singular)
- "`two`" (dual)
- "`few`" (paucal)
- "`many`" (also used for fractions if they have a separate class)
- "`other`" (required—general plural form—also used if the language only has a single form)

Again, we'll use English as the example here.

Let's read the `return` statement in the pluralRuleFunction above:

```javascript
return a
  ? 1 == t && 11 != r
    ? 'one'
    : 2 == t && 12 != r
    ? 'two'
    : 3 == t && 13 != r
    ? 'few'
    : 'other'
  : 1 == e && l
  ? 'one'
  : 'other';
```

This nested ternary is hard to read. It basically means:

```javascript
// e: the number variable to examine
// a: "true" if cardinals
// l: "true" if the variable e has nothin after decimal mark (e.g. "1.0" would be false)
// o: "true" if the variable e is an integer
// t: the "ones" of the number. e.g. "3" for number "9123"
// r: the "ones" and "tens" of the number. e.g. "23" for number "9123"
if (a == true) {
  if (t == 1 && r != 11) {
    return 'one'; // i.e. 1st, 21st, 101st, 121st ...
  } else if (t == 2 && r != 12) {
    return 'two'; // i.e. 2nd, 22nd, 102nd, 122nd ...
  } else if (t == 3 && r != 13) {
    return 'few'; // i.e. 3rd, 23rd, 103rd, 123rd ...
  } else {
    return 'other'; // i.e. 4th, 11th, 12th, 24th ...
  }
} else {
  if (e == 1 && l) {
    return 'one'; // i.e. 1 day
  } else {
    return 'other'; // i.e. 0 days, 2 days, 3 days
  }
}
```

If your language, like French, do not have complicated cardinal rules, you may
use the French's version of it:

```javascript
function (e, a) {
  return a ? 1 == e ? "one" : "other" : e >= 0 && e < 2 ? "one" : "other";
}
```

If your language, like Chinese, do not have any pluralization rule at all you
may use the Chinese's version of it:

```javascript
function (e, a) {
  return "other";
}
```

/*eslint eqeqeq: "off"*/
/*eslint no-nested-ternary: "off"*/
/*eslint quotes: "off"*/

export default [{
  locale: "co",
  pluralRuleFunction: function (e, a) {
    return a ? 1 == e ? "one" : "other" : e >= 0 && e < 2 ? "one" : "other";
  },
  fields: {
    year: {
      displayName: "annu",
      relative: {
        0: "quist'annu",
        1: "l'annu chì vene",
        "-1": "l'annu passatu",
      },
      relativeTime: {
        future: {
          one: "in {0} annu",
          other: "in {0} anni",
        },
        past: {
          one: "{0} annu fà",
          other: "{0} anni fà",
        },
      },
    },
    month: {
      displayName: "mese",
      relative: {
        0: "Questu mese",
        1: "u mese chì vene",
        "-1": "u mese passatu",
      },
      relativeTime: {
        future: {
          one: "in {0} mese",
          other: "in {0} mesi",
        },
        past: {
          one: "{0} mese fà",
          other: "{0} mesi fà",
        },
      },
    },
    day: {
      displayName: "ghjornu",
      relative: {
        0: "oghje",
        1: "dumane",
        "-1": "eri",
      },
      relativeTime: {
        future: {
          one: "in {0} ghjornu",
          other: "in {0} ghjornu",
        },
        past: {
          one: "{0} ghjornu fà",
          other: "{0} ghjorni fà",
        },
      },
    },
    hour: {
      displayName: "ora",
      relativeTime: {
        future: {
          one: "in {0} ora",
          other: "in {0} ore",
        },
        past: {
          one: "{0} ora fà",
          other: "{0} ore fà",
        },
      },
    },
    minute: {
      displayName: "minuta",
      relativeTime: {
        future: {
          one: "in {0} minuta",
          other: "in {0} minute",
        },
        past: {
          one: "{0} minuta fà",
          other: "{0} minute fà",
        },
      },
    },
    second: {
      displayName: "siconda",
      relative: {
        0: "avà",
      },
      relativeTime: {
        future: {
          one: "in {0} siconda",
          other: "in {0} siconde",
        },
        past: {
          one: "{0} siconda fà",
          other: "{0} siconde fà",
        },
      },
    },
  },
}];

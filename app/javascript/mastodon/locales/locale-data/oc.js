/*eslint eqeqeq: "off"*/
/*eslint no-nested-ternary: "off"*/
/*eslint quotes: "off"*/

const rules = [{
  locale: "oc",
  pluralRuleFunction: function (e, a) {
    return a ? 1 == e ? "one" : "other" : e >= 0 && e < 2 ? "one" : "other";
  },
  fields: {
    year: {
      displayName: "an",
      relative: {
        0: "ongan",
        1: "l'an que ven",
        "-1": "l'an passat",
      },
      relativeTime: {
        future: {
          one: "d’aquí {0} an",
          other: "d’aquí {0} ans",
        },
        past: {
          one: "fa {0} an",
          other: "fa {0} ans",
        },
      },
    },
    month: {
      displayName: "mes",
      relative: {
        0: "aqueste mes",
        1: "lo mes que ven",
        "-1": "lo mes passat",
      },
      relativeTime: {
        future: {
          one: "d’aquí {0} mes",
          other: "d’aquí {0} meses",
        },
        past: {
          one: "fa {0} mes",
          other: "fa {0} meses",
        },
      },
    },
    day: {
      displayName: "jorn",
      relative: {
        0: "uèi",
        1: "deman",
        "-1": "ièr",
      },
      relativeTime: {
        future: {
          one: "d’aquí {0} jorn",
          other: "d’aquí {0} jorns",
        },
        past: {
          one: "fa {0} jorn",
          other: "fa {0} jorns",
        },
      },
    },
    hour: {
      displayName: "ora",
      relativeTime: {
        future: {
          one: "d’aquí {0} ora",
          other: "d’aquí {0} oras",
        },
        past: {
          one: "fa {0} ora",
          other: "fa {0} oras",
        },
      },
    },
    minute: {
      displayName: "minuta",
      relativeTime: {
        future: {
          one: "d’aquí {0} minuta",
          other: "d’aquí {0} minutas",
        },
        past: {
          one: "fa {0} minuta",
          other: "fa {0} minutas",
        },
      },
    },
    second: {
      displayName: "segonda",
      relative: {
        0: "ara",
      },
      relativeTime: {
        future: {
          one: "d’aquí {0} segonda",
          other: "d’aquí {0} segondas",
        },
        past: {
          one: "fa {0} segonda",
          other: "fa {0} segondas",
        },
      },
    },
  },
}];

export default rules;

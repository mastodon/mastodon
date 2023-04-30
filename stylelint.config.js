module.exports = {
  extends: ['stylelint-config-standard-scss'],
  ignoreFiles: [
    'app/javascript/styles/mastodon/reset.scss',
    'app/javascript/flavours/glitch/styles/reset.scss',
    'app/javascript/styles/win95.scss',
    'coverage/**/*',
    'node_modules/**/*',
    'public/assets/**/*',
    'public/packs/**/*',
    'public/packs-test/**/*',
    'vendor/**/*',
  ],
  reportDescriptionlessDisables: true,
  reportInvalidScopeDisables: true,
  reportNeedlessDisables: true,
  rules: {
    'at-rule-empty-line-before': null,
    'color-function-notation': null,
    'color-hex-length': null,
    'declaration-block-no-redundant-longhand-properties': null,
    'no-descending-specificity': null,
    'no-duplicate-selectors': null,
    'number-max-precision': 8,
    'property-no-vendor-prefix': null,
    'selector-class-pattern': null,
    'selector-id-pattern': null,
    'value-keyword-case': null,
    'value-no-vendor-prefix': null,

    'scss/dollar-variable-empty-line-before': null,
    'scss/no-global-function-names': null,
  },
  overrides: [
    {
      'files': ['app/javascript/styles/mailer.scss'],
      rules: {
        'property-no-unknown': [
          true,
          {
            ignoreProperties: [
              '/^mso-/',
            ] },
        ],
      },
    },
  ],
};

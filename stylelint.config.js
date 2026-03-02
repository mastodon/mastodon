module.exports = {
  extends: ['stylelint-config-standard-scss', 'stylelint-config-prettier-scss'],
  ignoreFiles: [
    'app/javascript/styles/mastodon/reset.scss',
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
    'color-function-alias-notation': null,
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
      files: ['app/javascript/styles/entrypoints/mailer.scss'],
      rules: {
        'property-no-unknown': [
          true,
          {
            ignoreProperties: ['/^mso-/'],
          },
        ],
      },
    },
    {
      files: [
        'app/javascript/**/*.module.scss',
        'app/javascript/**/*.module.css',
      ],
      rules: {
        'selector-pseudo-class-no-unknown': [
          true,
          { ignorePseudoClasses: ['global'] },
        ],
      },
    },
  ],
};

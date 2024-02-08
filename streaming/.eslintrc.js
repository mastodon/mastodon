// @ts-check
const { defineConfig } = require('eslint-define-config');

module.exports = defineConfig({
  extends: ['../.eslintrc.js'],
  env: {
    browser: false,
  },
  parserOptions: {
    project: true,
    tsconfigRootDir: __dirname,
    ecmaFeatures: {
      jsx: false,
    },
    ecmaVersion: 2021,
  },
  rules: {
    // In the streaming server we need to delete some variables to ensure
    // garbage collection takes place on the values referenced by those objects;
    // The alternative is to declare the variable as nullable, but then we need
    // to assert it's in existence before every use, which becomes much harder
    // to maintain.
    'no-delete-var': 'off',

    // The streaming server is written in commonjs, not ESM for now:
    'import/no-commonjs': 'off',

    // This overrides the base configuration for this rule to pick up
    // dependencies for the streaming server from the correct package.json file.
    'import/no-extraneous-dependencies': [
      'error',
      {
        devDependencies: [
          'streaming/.eslintrc.js',
        ],
        optionalDependencies: false,
        peerDependencies: false,
        includeTypes: true,
        packageDir: __dirname,
      },
    ],
  },
});

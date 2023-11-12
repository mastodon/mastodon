// @ts-check
/** @type {import('eslint-define-config').ESLintConfig} */
module.exports = {
  extends: ['../.eslintrc.js'],
  parserOptions: {
    project: true,
    tsconfigRootDir: __dirname,
    ecmaFeatures: {
      jsx: false,
    },
    ecmaVersion: 2021,
  },
  rules: {
    'import/no-commonjs': 'off',
    'import/no-extraneous-dependencies': [
      'error',
      {
        devDependencies: false,
        optionalDependencies: false,
        peerDependencies: false,
        includeTypes: true,
        packageDir: __dirname,
      },
    ],
  },
};

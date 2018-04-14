module.exports = {
  'extends': 'airbnb',
  'rules': {
    'comma-dangle': ['error', 'never'],
    'import/no-unresolved': 'off',
    'import/no-extraneous-dependencies': 'off',
    'import/extensions': 'off',
    semi: ['error', 'never'],
  },
  'env': {
    'browser': true,
    'node': true,
  },
};

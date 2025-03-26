// eslint-disable-next-line import/no-extraneous-dependencies
import globals from 'globals';
// eslint-disable-next-line import/no-extraneous-dependencies
import tseslint from 'typescript-eslint';

// eslint-disable-next-line import/no-relative-packages
import mastodonEslintConfig from '../eslint.config.mjs';

export default tseslint.config([
  mastodonEslintConfig,
  {
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node,
      },

      ecmaVersion: 2021,
      sourceType: 'script',
    },

    rules: {
      'no-delete-var': 'off',

      'import/no-extraneous-dependencies': [
        'error',
        {
          devDependencies: ['streaming/eslint.config.mjs'],
          optionalDependencies: false,
          peerDependencies: false,
          includeTypes: true,
          packageDir: import.meta.dirname,
        },
      ],

      'import/extensions': ['error', 'always'],
    },
  },
]);

// @ts-check

import globals from 'globals';
import tseslint from 'typescript-eslint';

// eslint-disable-next-line import/no-relative-packages -- Must import from the root
import { baseConfig } from '../eslint.config.mjs';

export default tseslint.config([
  baseConfig,
  {
    languageOptions: {
      globals: globals.node,

      parser: tseslint.parser,
      ecmaVersion: 2021,
      sourceType: 'module',
    },

    settings: {
      'import/ignore': ['node_modules', '\\.(json)$'],
      'import/resolver': {
        typescript: {},
      },
    },

    rules: {
      'no-delete-var': 'off',

      'import/no-extraneous-dependencies': [
        'error',
        {
          devDependencies: ['**/*.config.mjs'],
        },
      ],

      'import/extensions': ['error', 'always'],

      // TODO: Fix resolution of imports
      // 'import/no-unresolved': ['error', { ignore: ['typescript-eslint'] }]
    },
  },
]);

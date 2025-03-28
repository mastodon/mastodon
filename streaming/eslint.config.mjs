// @ts-check

import globals from 'globals';
import tseslint from 'typescript-eslint';

import { baseConfig } from '../eslint.config.mjs';

export default tseslint.config([
  baseConfig,
  {
    languageOptions: {
      globals: globals.node,

      ecmaVersion: 2021,
      sourceType: 'module',
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

      // TODO: Fix resolution of imports
      'import/no-unresolved': 'off',
    },
  },
]);

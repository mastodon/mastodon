// @ts-check

import path from 'node:path';

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
        typescript: {
          project: path.resolve(import.meta.dirname, './tsconfig.json'),
        },
      },
    },

    rules: {
      // In the streaming server we need to delete some variables to ensure
      // garbage collection takes place on the values referenced by those objects;
      // The alternative is to declare the variable as nullable, but then we need
      // to assert it's in existence before every use, which becomes much harder
      // to maintain.
      'no-delete-var': 'off',

      'import/no-extraneous-dependencies': [
        'error',
        {
          devDependencies: ['**/*.config.mjs'],
        },
      ],

      'import/extensions': ['error', 'always'],
    },
  },
]);

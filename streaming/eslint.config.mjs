import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { FlatCompat } from '@eslint/eslintrc';
import js from '@eslint/js';
import { defineConfig } from 'eslint/config';
import globals from 'globals';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all,
});

export default defineConfig([
  {
    extends: compat.extends('../eslint.config.mjs'),

    languageOptions: {
      globals: {
        ...Object.fromEntries(
          Object.entries(globals.browser).map(([key]) => [key, 'off']),
        ),
      },

      ecmaVersion: 2021,
      sourceType: 'script',

      parserOptions: {
        project: true,
        tsconfigRootDir: import.meta.dirname,

        ecmaFeatures: {
          jsx: false,
        },
      },
    },

    rules: {
      'no-delete-var': 'off',

      'import/no-extraneous-dependencies': [
        'error',
        {
          devDependencies: ['**/eslint.config.mjs'],
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

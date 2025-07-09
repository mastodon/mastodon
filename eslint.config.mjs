// @ts-check

import path from 'node:path';

import js from '@eslint/js';
import { globalIgnores } from 'eslint/config';
import formatjs from 'eslint-plugin-formatjs';
// @ts-expect-error -- No typings
import importPlugin from 'eslint-plugin-import';
import jsdoc from 'eslint-plugin-jsdoc';
import jsxA11Y from 'eslint-plugin-jsx-a11y';
import promisePlugin from 'eslint-plugin-promise';
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';
import storybook from 'eslint-plugin-storybook';
import globals from 'globals';
import tseslint from 'typescript-eslint';

/** @type {import('typescript-eslint').ConfigArray} */
export const baseConfig = [
  js.configs.recommended,
  importPlugin.flatConfigs.recommended,
  jsdoc.configs['flat/recommended'],
  promisePlugin.configs['flat/recommended'],
  {
    linterOptions: {
      reportUnusedDisableDirectives: 'error',
      reportUnusedInlineConfigs: 'error',
    },
    rules: {
      'consistent-return': 'error',
      'dot-notation': 'error',

      eqeqeq: [
        'error',
        'always',
        {
          null: 'ignore',
        },
      ],

      'no-console': [
        'warn',
        {
          allow: ['error', 'warn'],
        },
      ],

      'no-empty': [
        'error',
        {
          allowEmptyCatch: true,
        },
      ],

      'no-restricted-properties': [
        'error',
        {
          property: 'substring',
          message: 'Use .slice instead of .substring.',
        },
        {
          property: 'substr',
          message: 'Use .slice instead of .substr.',
        },
      ],

      'no-unused-expressions': 'error',
      'no-unused-vars': 'off',

      'valid-typeof': 'error',

      'import/extensions': [
        'error',
        'always',
        {
          js: 'never',
          jsx: 'never',
          mjs: 'never',
          ts: 'never',
          mts: 'never',
          tsx: 'never',
        },
      ],
      'import/first': 'error',
      'import/newline-after-import': 'error',
      'import/no-anonymous-default-export': 'error',
      'import/no-amd': 'error',
      'import/no-commonjs': 'error',
      'import/no-import-module-exports': 'error',
      'import/no-relative-packages': 'error',
      'import/no-self-import': 'error',
      'import/no-useless-path-segments': 'error',
      'import/order': [
        'error',
        {
          alphabetize: {
            order: 'asc',
          },

          'newlines-between': 'always',

          groups: [
            'builtin',
            'external',
            'internal',
            'parent',
            ['index', 'sibling'],
            'object',
          ],

          pathGroups: [
            {
              pattern: '{react,react-dom,react-dom/client,prop-types}',
              group: 'builtin',
              position: 'after',
            },
            {
              pattern: '{react-intl,intl-messageformat}',
              group: 'builtin',
              position: 'after',
            },
            {
              pattern:
                '{classnames,react-helmet,react-router,react-router-dom}',
              group: 'external',
              position: 'before',
            },
            {
              pattern:
                '{immutable,@reduxjs/toolkit,react-redux,react-immutable-proptypes,react-immutable-pure-component}',
              group: 'external',
              position: 'before',
            },
            {
              pattern: '{mastodon/**}',
              group: 'internal',
              position: 'after',
            },
          ],

          pathGroupsExcludedImportTypes: [],
        },
      ],

      'jsdoc/check-types': 'off',
      'jsdoc/no-undefined-types': 'off',
      'jsdoc/require-jsdoc': 'off',
      'jsdoc/require-param-description': 'off',
      'jsdoc/require-property-description': 'off',
      'jsdoc/require-returns-description': 'off',
      'jsdoc/require-returns': 'off',

      'promise/always-return': 'off',
      'promise/catch-or-return': [
        'error',
        {
          allowFinally: true,
        },
      ],
      'promise/no-callback-in-promise': 'off',
      'promise/no-nesting': 'off',
      'promise/no-promise-in-callback': 'off',
    },
  },
];

export default tseslint.config([
  baseConfig,
  globalIgnores([
    'build/**/*',
    'coverage/**/*',
    'db/**/*',
    'lib/**/*',
    'log/**/*',
    'node_modules/**/*',
    'public/**/*',
    '!public/embed.js',
    'spec/**/*',
    'tmp/**/*',
    'vendor/**/*',
    'streaming/**/*',
  ]),
  react.configs.flat.recommended,
  react.configs.flat['jsx-runtime'],
  reactHooks.configs['recommended-latest'],
  jsxA11Y.flatConfigs.recommended,
  importPlugin.flatConfigs.react,
  // @ts-expect-error -- For some reason the formatjs package exports an empty object?
  formatjs.configs.strict,
  storybook.configs['flat/recommended'],
  {
    languageOptions: {
      globals: {
        ...globals.browser,
      },

      parser: tseslint.parser,
      ecmaVersion: 2021,
      sourceType: 'module',
    },

    settings: {
      react: {
        version: 'detect',
      },

      'import/ignore': ['node_modules', '\\.(css|scss|json)$'],

      'import/resolver': {
        typescript: {
          project: path.resolve(import.meta.dirname, './tsconfig.json'),
        },
      },
    },

    rules: {
      'no-restricted-syntax': [
        'error',
        {
          // eslint-disable-next-line no-restricted-syntax
          selector: 'Literal[value=/•/], JSXText[value=/•/]',
          // eslint-disable-next-line no-restricted-syntax
          message: "Use '·' (middle dot) instead of '•' (bullet)",
        },
      ],

      'formatjs/enforce-description': 'off', // description values not currently used
      'formatjs/enforce-id': 'off', // Explicit IDs are used in the project
      'formatjs/enforce-placeholders': 'off', // Issues in short_number.jsx
      'formatjs/no-invalid-icu': 'error',
      'formatjs/no-literal-string-in-jsx': 'off', // Should be looked at, but mainly flagging punctuation outside of strings
      'formatjs/no-multiple-plurals': 'off', // Should be looked at

      'jsx-a11y/click-events-have-key-events': 'off',
      'jsx-a11y/label-has-associated-control': 'off',
      'jsx-a11y/media-has-caption': 'off',
      'jsx-a11y/no-autofocus': 'off',
      'jsx-a11y/no-interactive-element-to-noninteractive-role': 'off',
      'jsx-a11y/no-noninteractive-tabindex': 'off',
      'jsx-a11y/no-static-element-interactions': [
        'warn',
        {
          handlers: ['onClick'],
        },
      ],

      'import/no-extraneous-dependencies': [
        'error',
        {
          devDependencies: [
            'eslint.config.mjs',
            'app/javascript/mastodon/performance.js',
            'app/javascript/testing/**/*',
            'app/javascript/**/__tests__/**',
            'app/javascript/**/*.stories.ts',
            'app/javascript/**/*.stories.tsx',
            'app/javascript/**/*.test.ts',
            'app/javascript/**/*.test.tsx',
            '.storybook/**/*',
          ],
        },
      ],
      'import/no-unresolved': [
        'error',
        {
          ignore: ['vite/modulepreload-polyfill', '^virtual:.+'],
        },
      ],

      'react/jsx-filename-extension': [
        'error',
        {
          extensions: ['.jsx', 'tsx'],
        },
      ],

      'react/jsx-boolean-value': 'error',
      'react/display-name': 'off',
      'react/jsx-fragments': ['error', 'syntax'],
      'react/jsx-equals-spacing': 'error',
      'react/jsx-no-bind': 'error',
      'react/jsx-no-useless-fragment': 'error',
      'react/jsx-no-target-blank': [
        'error',
        {
          allowReferrer: true,
        },
      ],
      'react/jsx-tag-spacing': 'error',
      'react/jsx-wrap-multilines': 'error',
      'react/self-closing-comp': 'error',
    },
  },
  {
    files: [
      'app/javascript/mastodon/common.js',
      'app/javascript/mastodon/features/emoji/unicode_to_unified_name.js',
      'app/javascript/mastodon/features/emoji/emoji_compressed.js',
      'app/javascript/mastodon/features/emoji/unicode_to_filename.js',
      'app/javascript/mastodon/service_worker/web_push_locales.js',
      '**/*.config.js',
      '**/.*rc.js',
      '**/ide-helper.js',
      'config/formatjs-formatter.js',
    ],

    languageOptions: {
      globals: {
        ...globals.commonjs,
        ...globals.node,
      },

      ecmaVersion: 5,
      sourceType: 'commonjs',
    },

    rules: {
      'import/no-commonjs': 'off',
    },
  },
  {
    files: ['**/*.ts', '**/*.tsx'],

    extends: [
      tseslint.configs.strictTypeChecked,
      tseslint.configs.stylisticTypeChecked,
      react.configs.flat.recommended,
      react.configs.flat['jsx-runtime'],
      reactHooks.configs['recommended-latest'],
      jsxA11Y.flatConfigs.recommended,
      importPlugin.flatConfigs.react,
      importPlugin.flatConfigs.typescript,
      jsdoc.configs['flat/recommended-typescript'],
    ],

    languageOptions: {
      parserOptions: {
        projectService: true,
      },
    },

    rules: {
      // This is not needed as we use noImplicitReturns, which handles this in addition to understanding types
      'consistent-return': 'off',

      'formatjs/enforce-plural-rules': 'off',

      'import/consistent-type-specifier-style': ['error', 'prefer-top-level'],
      'import/no-default-export': 'warn',

      'jsdoc/require-jsdoc': 'off',

      'react/prefer-stateless-function': 'warn',
      'react/function-component-definition': [
        'error',
        {
          namedComponents: 'arrow-function',
        },
      ],
      'react/prop-types': 'off',

      '@typescript-eslint/consistent-type-definitions': ['warn', 'interface'],
      '@typescript-eslint/consistent-type-exports': 'error',
      '@typescript-eslint/consistent-type-imports': 'error',
      '@typescript-eslint/prefer-nullish-coalescing': [
        'error',
        {
          ignorePrimitives: {
            boolean: true,
          },
        },
      ],
      '@typescript-eslint/no-restricted-imports': [
        'warn',
        {
          name: 'react-redux',
          importNames: ['useSelector', 'useDispatch'],
          message:
            'Use typed hooks `useAppDispatch` and `useAppSelector` instead.',
        },
      ],
      '@typescript-eslint/no-unused-vars': [
        'error',
        {
          vars: 'all',
          args: 'after-used',
          destructuredArrayIgnorePattern: '^_',
          ignoreRestSiblings: true,
        },
      ],
      '@typescript-eslint/restrict-template-expressions': [
        'warn',
        {
          allowNumber: true,
        },
      ],
    },
  },
  {
    files: ['**/__tests__/*.js', '**/__tests__/*.jsx'],

    languageOptions: {
      globals: globals.vitest,
    },
  },
  {
    files: ['**/*.stories.ts', '**/*.stories.tsx', '.storybook/*'],
    rules: {
      'import/no-default-export': 'off',
    },
  },
  {
    files: ['vitest.shims.d.ts'],
    rules: {
      '@typescript-eslint/no-unnecessary-boolean-literal-compare': 'off',
      '@typescript-eslint/no-unnecessary-condition': 'off',
      '@typescript-eslint/prefer-nullish-coalescing': 'off',
    },
  },
]);

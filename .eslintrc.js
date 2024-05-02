// @ts-check
const { defineConfig } = require('eslint-define-config');

module.exports = defineConfig({
  root: true,

  extends: [
    'eslint:recommended',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
    'plugin:jsx-a11y/recommended',
    'plugin:import/recommended',
    'plugin:promise/recommended',
    'plugin:jsdoc/recommended',
  ],

  env: {
    browser: true,
    node: true,
    es6: true,
  },

  globals: {
    ATTACHMENT_HOST: false,
  },

  parser: '@typescript-eslint/parser',

  plugins: [
    'react',
    'jsx-a11y',
    'import',
    'promise',
    '@typescript-eslint',
    'formatjs',
  ],

  parserOptions: {
    sourceType: 'module',
    ecmaFeatures: {
      jsx: true,
    },
    ecmaVersion: 2021,
    requireConfigFile: false,
    babelOptions: {
      configFile: false,
      presets: ['@babel/react', '@babel/env'],
    },
  },

  settings: {
    react: {
      version: 'detect',
    },
    'import/ignore': [
      'node_modules',
      '\\.(css|scss|json)$',
    ],
    'import/resolver': {
      typescript: {},
    },
  },

  rules: {
    'consistent-return': 'error',
    'dot-notation': 'error',
    eqeqeq: ['error', 'always', { 'null': 'ignore' }],
    'indent': ['error', 2],
    'jsx-quotes': ['error', 'prefer-single'],
    'semi': ['error', 'always'],
    'no-case-declarations': 'off',
    'no-catch-shadow': 'error',
    'no-console': [
      'warn',
      {
        allow: [
          'error',
          'warn',
        ],
      },
    ],
    'no-empty': 'off',
    'no-restricted-properties': [
      'error',
      { property: 'substring', message: 'Use .slice instead of .substring.' },
      { property: 'substr', message: 'Use .slice instead of .substr.' },
    ],
    'no-restricted-syntax': [
      'error',
      {
        // eslint-disable-next-line no-restricted-syntax
        selector: 'Literal[value=/•/], JSXText[value=/•/]',
        // eslint-disable-next-line no-restricted-syntax
        message: "Use '·' (middle dot) instead of '•' (bullet)",
      },
    ],
    'no-self-assign': 'off',
    'no-unused-expressions': 'error',
    'no-unused-vars': 'off',
    '@typescript-eslint/no-unused-vars': [
      'error',
      {
        vars: 'all',
        args: 'after-used',
        destructuredArrayIgnorePattern: '^_',
        ignoreRestSiblings: true,
      },
    ],
    'valid-typeof': 'error',

    'react/jsx-filename-extension': ['error', { extensions: ['.jsx', 'tsx'] }],
    'react/jsx-boolean-value': 'error',
    'react/display-name': 'off',
    'react/jsx-fragments': ['error', 'syntax'],
    'react/jsx-equals-spacing': 'error',
    'react/jsx-no-bind': 'error',
    'react/jsx-no-useless-fragment': 'error',
    'react/jsx-no-target-blank': 'off',
    'react/jsx-tag-spacing': 'error',
    'react/jsx-uses-react': 'off', // not needed with new JSX transform
    'react/jsx-wrap-multilines': 'error',
    'react/no-deprecated': 'off',
    'react/react-in-jsx-scope': 'off', // not needed with new JSX transform
    'react/self-closing-comp': 'error',

    // recommended values found in https://github.com/jsx-eslint/eslint-plugin-jsx-a11y/blob/v6.8.0/src/index.js#L46
    'jsx-a11y/accessible-emoji': 'warn',
    'jsx-a11y/click-events-have-key-events': 'off',
    'jsx-a11y/label-has-associated-control': 'off',
    'jsx-a11y/media-has-caption': 'off',
    'jsx-a11y/no-autofocus': 'off',
    // recommended rule is:
    // 'jsx-a11y/no-interactive-element-to-noninteractive-role': [
    //   'error',
    //   {
    //     tr: ['none', 'presentation'],
    //     canvas: ['img'],
    //   },
    // ],
    'jsx-a11y/no-interactive-element-to-noninteractive-role': 'off',
    // recommended rule is:
    // 'jsx-a11y/no-noninteractive-element-interactions': [
    //   'error',
    //   {
    //     body: ['onError', 'onLoad'],
    //     iframe: ['onError', 'onLoad'],
    //     img: ['onError', 'onLoad'],
    //   },
    // ],
    'jsx-a11y/no-noninteractive-element-interactions': [
      'warn',
      {
        handlers: [
          'onClick',
        ],
      },
    ],
    // recommended rule is:
    // 'jsx-a11y/no-noninteractive-tabindex': [
    //   'error',
    //   {
    //     tags: [],
    //     roles: ['tabpanel'],
    //     allowExpressionValues: true,
    //   },
    // ],
    'jsx-a11y/no-noninteractive-tabindex': 'off',
    'jsx-a11y/no-onchange': 'off',
    // recommended is full 'error'
    'jsx-a11y/no-static-element-interactions': [
      'warn',
      {
        handlers: [
          'onClick',
        ],
      },
    ],

    // See https://github.com/import-js/eslint-plugin-import/blob/v2.29.1/config/recommended.js
    'import/extensions': [
      'error',
      'always',
      {
        js: 'never',
        jsx: 'never',
        mjs: 'never',
        ts: 'never',
        tsx: 'never',
      },
    ],
    'import/first': 'error',
    'import/newline-after-import': 'error',
    'import/no-anonymous-default-export': 'error',
    'import/no-extraneous-dependencies': [
      'error',
      {
        devDependencies: [
          '.eslintrc.js',
          'config/webpack/**',
          'app/javascript/mastodon/performance.js',
          'app/javascript/mastodon/test_setup.js',
          'app/javascript/**/__tests__/**',
        ],
      },
    ],
    'import/no-amd': 'error',
    'import/no-commonjs': 'error',
    'import/no-import-module-exports': 'error',
    'import/no-relative-packages': 'error',
    'import/no-self-import': 'error',
    'import/no-useless-path-segments': 'error',
    'import/no-webpack-loader-syntax': 'error',

    'import/order': [
      'error',
      {
        alphabetize: { order: 'asc' },
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
          // React core packages
          {
            pattern: '{react,react-dom,react-dom/client,prop-types}',
            group: 'builtin',
            position: 'after',
          },
          // I18n
          {
            pattern: '{react-intl,intl-messageformat}',
            group: 'builtin',
            position: 'after',
          },
          // Common React utilities
          {
            pattern: '{classnames,react-helmet,react-router,react-router-dom}',
            group: 'external',
            position: 'before',
          },
          // Immutable / Redux / data store
          {
            pattern: '{immutable,@reduxjs/toolkit,react-redux,react-immutable-proptypes,react-immutable-pure-component}',
            group: 'external',
            position: 'before',
          },
          // Internal packages
          {
            pattern: '{mastodon/**}',
            group: 'internal',
            position: 'after',
          },
          {
            pattern: '{flavours/glitch-soc/**}',
            group: 'internal',
            position: 'after',
          },
        ],
        pathGroupsExcludedImportTypes: [],
      },
    ],

    // Forbid imports from vanilla in glitch flavour
    'import/no-restricted-paths': [
      'error',
      {
        zones: [{
          target: 'app/javascript/flavours/glitch/',
          from: 'app/javascript/mastodon/',
          message: 'Import from /flavours/glitch/ instead'
        }]
      }
    ],

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

    'formatjs/blocklist-elements': 'error',
    'formatjs/enforce-default-message': ['error', 'literal'],
    'formatjs/enforce-description': 'off', // description values not currently used
    'formatjs/enforce-id': 'off', // Explicit IDs are used in the project
    'formatjs/enforce-placeholders': 'off', // Issues in short_number.jsx
    'formatjs/enforce-plural-rules': 'error',
    'formatjs/no-camel-case': 'off', // disabledAccount is only non-conforming
    'formatjs/no-complex-selectors': 'error',
    'formatjs/no-emoji': 'error',
    'formatjs/no-id': 'off', // IDs are used for translation keys
    'formatjs/no-invalid-icu': 'error',
    'formatjs/no-literal-string-in-jsx': 'off', // Should be looked at, but mainly flagging punctuation outside of strings
    'formatjs/no-multiple-whitespaces': 'error',
    'formatjs/no-offset': 'error',
    'formatjs/no-useless-message': 'error',
    'formatjs/prefer-formatted-message': 'error',
    'formatjs/prefer-pound-in-plural': 'error',

    'jsdoc/check-types': 'off',
    'jsdoc/no-undefined-types': 'off',
    'jsdoc/require-jsdoc': 'off',
    'jsdoc/require-param-description': 'off',
    'jsdoc/require-property-description': 'off',
    'jsdoc/require-returns-description': 'off',
    'jsdoc/require-returns': 'off',
  },

  overrides: [
    {
      files: [
        '.eslintrc.js',
        '*.config.js',
        '.*rc.js',
        'ide-helper.js',
        'config/webpack/**/*',
        'config/formatjs-formatter.js',
      ],

      env: {
        commonjs: true,
      },

      parserOptions: {
        sourceType: 'script',
      },

      rules: {
        'import/no-commonjs': 'off',
      },
    },
    {
      files: [
        '**/*.ts',
        '**/*.tsx',
      ],

      extends: [
        'eslint:recommended',
        'plugin:@typescript-eslint/strict-type-checked',
        'plugin:@typescript-eslint/stylistic-type-checked',
        'plugin:react/recommended',
        'plugin:react-hooks/recommended',
        'plugin:jsx-a11y/recommended',
        'plugin:import/recommended',
        'plugin:import/typescript',
        'plugin:promise/recommended',
        'plugin:jsdoc/recommended-typescript',
      ],

      parserOptions: {
        project: true,
        tsconfigRootDir: __dirname,
      },

      rules: {
        // Disable formatting rules that have been enabled in the base config
        'indent': 'off',

        'import/consistent-type-specifier-style': ['error', 'prefer-top-level'],

        '@typescript-eslint/consistent-type-definitions': ['warn', 'interface'],
        '@typescript-eslint/consistent-type-exports': 'error',
        '@typescript-eslint/consistent-type-imports': 'error',
        "@typescript-eslint/prefer-nullish-coalescing": ['error', { ignorePrimitives: { boolean: true } }],
        "@typescript-eslint/no-restricted-imports": [
          "warn",
          {
            "name": "react-redux",
            "importNames": ["useSelector", "useDispatch"],
            "message": "Use typed hooks `useAppDispatch` and `useAppSelector` instead."
          }
        ],
        "@typescript-eslint/restrict-template-expressions": ['warn', { allowNumber: true }],
        'jsdoc/require-jsdoc': 'off',

        // Those rules set stricter rules for TS files
        // to enforce better practices when converting from JS
        'import/no-default-export': 'warn',
        'react/prefer-stateless-function': 'warn',
        'react/function-component-definition': ['error', { namedComponents: 'arrow-function' }],
        'react/jsx-uses-react': 'off', // not needed with new JSX transform
        'react/react-in-jsx-scope': 'off', // not needed with new JSX transform
        'react/prop-types': 'off',
      },
    },
    {
      files: [
        '**/__tests__/*.js',
        '**/__tests__/*.jsx',
      ],

      env: {
        jest: true,
      },
    }
  ],
});

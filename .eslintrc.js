module.exports = {
  root: true,

  extends: [
    'eslint:recommended',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
    'plugin:jsx-a11y/recommended',
    'plugin:import/recommended',
    'plugin:promise/recommended',
    'plugin:jsdoc/recommended',
    'plugin:prettier/recommended',
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
    'jsx-quotes': ['error', 'prefer-single'],
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
    'react/no-unknown-property': 'off',
    'react/react-in-jsx-scope': 'off', // not needed with new JSX transform
    'react/self-closing-comp': 'error',

    // recommended values found in https://github.com/jsx-eslint/eslint-plugin-jsx-a11y/blob/main/src/index.js
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
    'jsx-a11y/no-onchange': 'warn',
    // recommended is full 'error'
    'jsx-a11y/no-static-element-interactions': [
      'warn',
      {
        handlers: [
          'onClick',
        ],
      },
    ],

    // See https://github.com/import-js/eslint-plugin-import/blob/main/config/recommended.js
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
            pattern: '{classnames,react-helmet,react-router-dom}',
            group: 'external',
            position: 'before',
          },
          // Immutable / Redux / data store
          {
            pattern: '{immutable,react-redux,react-immutable-proptypes,react-immutable-pure-component,reselect}',
            group: 'external',
            position: 'before',
          },
          // Internal packages
          {
            pattern: '{mastodon/**,flavours/glitch-soc/**}',
            group: 'internal',
            position: 'after',
          },
        ],
        pathGroupsExcludedImportTypes: [],
      },
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
    'formatjs/no-multiple-plurals': 'off', // Only used by hashtag.jsx
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
        '*.config.js',
        '.*rc.js',
        'ide-helper.js',
        'config/webpack/**/*',
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
        'plugin:@typescript-eslint/recommended',
        'plugin:@typescript-eslint/recommended-requiring-type-checking',
        'plugin:react/recommended',
        'plugin:react-hooks/recommended',
        'plugin:jsx-a11y/recommended',
        'plugin:import/recommended',
        'plugin:import/typescript',
        'plugin:promise/recommended',
        'plugin:jsdoc/recommended',
        'plugin:prettier/recommended',
      ],

      parserOptions: {
        project: './tsconfig.json',
        tsconfigRootDir: __dirname,
      },

      rules: {
        'import/consistent-type-specifier-style': ['error', 'prefer-top-level'],

        '@typescript-eslint/consistent-type-definitions': ['warn', 'interface'],
        '@typescript-eslint/consistent-type-exports': 'error',
        '@typescript-eslint/consistent-type-imports': 'error',

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
    },
    {
      files: [
        'streaming/**/*',
      ],
      rules: {
        'import/no-commonjs': 'off',
      },
    },
  ],
};

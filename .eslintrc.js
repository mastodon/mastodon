module.exports = {
  root: true,

  extends: [
    'eslint:recommended',
    'plugin:react/recommended',
    'plugin:jsx-a11y/recommended',
    'plugin:import/recommended',
    'plugin:promise/recommended',
  ],

  env: {
    browser: true,
    node: true,
    es6: true,
    jest: true,
  },

  globals: {
    ATTACHMENT_HOST: false,
  },

  parser: '@babel/eslint-parser',

  plugins: [
    'react',
    'jsx-a11y',
    'import',
    'promise',
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
    'import/extensions': [
      '.js', '.jsx',
    ],
    'import/ignore': [
      'node_modules',
      '\\.(css|scss|json)$',
    ],
    'import/resolver': {
      node: {
        paths: ['app/javascript'],
        extensions: ['.js', '.jsx'],
      },
    },
  },

  rules: {
    'brace-style': 'warn',
    'comma-dangle': ['error', 'always-multiline'],
    'comma-spacing': [
      'warn',
      {
        before: false,
        after: true,
      },
    ],
    'comma-style': ['warn', 'last'],
    'consistent-return': 'error',
    'dot-notation': 'error',
    eqeqeq: 'error',
    indent: ['warn', 2],
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
    'no-trailing-spaces': 'warn',
    'no-unused-expressions': 'error',
    'no-unused-vars': [
      'error',
      {
        vars: 'all',
        args: 'after-used',
        ignoreRestSiblings: true,
      },
    ],
    'object-curly-spacing': ['error', 'always'],
    'padded-blocks': [
      'error',
      {
        classes: 'always',
      },
    ],
    quotes: ['error', 'single'],
    semi: 'error',
    'valid-typeof': 'error',

    'react/jsx-filename-extension': ['error', { 'allow': 'as-needed' }],
    'react/jsx-boolean-value': 'error',
    'react/jsx-closing-bracket-location': ['error', 'line-aligned'],
    'react/jsx-curly-spacing': 'error',
    'react/display-name': 'off',
    'react/jsx-equals-spacing': 'error',
    'react/jsx-first-prop-new-line': ['error', 'multiline-multiprop'],
    'react/jsx-indent': ['error', 2],
    'react/jsx-no-bind': 'error',
    'react/jsx-no-target-blank': 'off',
    'react/jsx-tag-spacing': 'error',
    'react/jsx-wrap-multilines': 'error',
    'react/no-deprecated': 'off',
    'react/no-unknown-property': 'off',
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
      },
    ],
    'import/newline-after-import': 'error',
    'import/no-extraneous-dependencies': [
      'error',
      {
        devDependencies: [
          'config/webpack/**',
          'app/javascript/mastodon/test_setup.js',
          'app/javascript/**/__tests__/**',
        ],
      },
    ],
    'import/no-webpack-loader-syntax': 'error',

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

  overrides: [
    {
      files: [
        '*.config.js',
        '.*rc.js',
        'ide-helper.js',
      ],

      env: {
        commonjs: true,
      },

      parserOptions: {
        sourceType: 'script',
      },
    },
  ],
};

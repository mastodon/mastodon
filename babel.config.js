module.exports = (api) => {
  const isDev = api.env() === 'development';

  const envOptions = {
    loose: true,
    modules: false,
    debug: isDev,
    include: [
      'proposal-numeric-separator',
    ],
  };

  const config = {
    presets: [
      '@babel/preset-typescript',
      ['@babel/react', {
        development: isDev,
      }],
      ['@babel/env', envOptions],
    ],
    plugins: [
      ['react-intl', { messagesDir: './build/messages' }],
      'preval',
      '@babel/plugin-proposal-optional-chaining',
      '@babel/plugin-proposal-nullish-coalescing-operator',
      'lodash',
      [
        'transform-react-remove-prop-types',
        {
          mode: 'remove',
          removeImport: true,
          additionalLibraries: [
            'react-immutable-proptypes',
          ],
        },
      ],
      '@babel/transform-react-inline-elements',
      [
        '@babel/transform-runtime',
        {
          helpers: true,
          regenerator: false,
          useESModules: true,
        },
      ],
    ],
    overrides: [
      {
        test: /tesseract\.js/,
        presets: [
          ['@babel/env', { ...envOptions, modules: 'commonjs' }],
        ],
      },
    ],
  };

  return config;
};

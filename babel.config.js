module.exports = (api) => {
  const env = api.env();

  const reactOptions = {
    development: false,
  };

  const envOptions = {
    loose: true,
    modules: false,
    debug: false,
    include: [
      'proposal-numeric-separator',
    ],
  };

  const config = {
    presets: [
      '@babel/preset-typescript',
      ['@babel/react', reactOptions],
      ['@babel/env', envOptions],
    ],
    plugins: [
      ['react-intl', { messagesDir: './build/messages' }],
      'preval',
      '@babel/plugin-proposal-optional-chaining',
      '@babel/plugin-proposal-nullish-coalescing-operator',
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

  switch (env) {
  case 'production':
    config.plugins.push(...[
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
    ]);
    break;
  case 'development':
    reactOptions.development = true;
    envOptions.debug = true;
    break;
  case 'test':
    envOptions.modules = 'commonjs';
    break;
  }

  return config;
};

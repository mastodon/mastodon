module.exports = (api) => {
  const env = api.env();

  const reactOptions = {
    development: false,
    runtime: 'automatic',
  };

  const envOptions = {
    loose: true,
    modules: false,
    debug: false,
    include: [
      'transform-numeric-separator',
      'transform-optional-chaining',
      'transform-nullish-coalescing-operator',
      'transform-class-properties',
    ],
  };

  const config = {
    presets: [
      '@babel/preset-typescript',
      ['@babel/react', reactOptions],
      ['@babel/env', envOptions],
    ],
    plugins: [
      ['formatjs'],
      'preval',
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

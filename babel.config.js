module.exports = (api) => {
  const env = api.env();

  const reactOptions = {
    development: false,
    runtime: 'automatic',
  };

  const envOptions = {
    useBuiltIns: "usage",
    corejs: { version: "3.30" },
    debug: false,
    include: [
      'transform-numeric-separator',
      'transform-optional-chaining',
      'transform-nullish-coalescing-operator',
      'transform-class-properties',
    ],
  };

  const plugins = [
    ['formatjs'],
    'preval',
  ];

  switch (env) {
  case 'production':
    plugins.push(...[
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

    // We need Babel to not inject polyfills in dev, as this breaks `preval` files
    envOptions.useBuiltIns = false;
    envOptions.corejs = undefined;
    break;
  }

  const config = {
    presets: [
      '@babel/preset-typescript',
      ['@babel/react', reactOptions],
      ['@babel/env', envOptions],
    ],
    plugins,
    overrides: [
      {
        test: [/tesseract\.js/, /fuzzysort\.js/],
        presets: [
          ['@babel/env', { ...envOptions, modules: 'commonjs' }],
        ],
      },
    ],
  };

  return config;
};

var path = require('path');

module.exports = {
  test: /\.(ts|tsx)$/,
  use: [
    {
      loader: 'ts-loader',
      options: {
        configFile: path.resolve(__dirname, '../tsconfig.json'),
      },
    },
  ],
  exclude: /node_modules/,
};

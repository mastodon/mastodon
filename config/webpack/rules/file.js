const { join } = require('path');

const { settings } = require('../configuration');

module.exports = {
  test: new RegExp(`(${settings.static_assets_extensions.join('|')})$`, 'i'),
  exclude: [/material-icons/, /svg-icons/],
  use: [
    {
      loader: 'file-loader',
      options: {
        name(file) {
          if (file.includes(settings.source_path)) {
            return 'media/[path][name]-[hash].[ext]';
          }
          return 'media/[folder]/[name]-[hash:8].[ext]';
        },
        context: join(settings.source_path),
      },
    },
  ],
};

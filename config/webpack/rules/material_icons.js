module.exports = {
  test: /\.svg$/,
  include: [/material-icons/, /svg-icons/],
  issuer: /\.[jt]sx?$/,
  use: [
    {
      loader: '@svgr/webpack',
      options: {
        svgo: false,
        titleProp: true,
      },
    },
  ],
};

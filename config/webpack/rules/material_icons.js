module.exports = {
  test: /\.svg$/,
  include: /node_modules\/@material-symbols/,
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

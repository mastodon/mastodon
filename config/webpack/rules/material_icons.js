module.exports = {
  test: /\.svg$/,
  include: /node_modules\/@material-design-icons/,
  issuer: /\.[jt]sx?$/,
  use: [
    {
      loader: '@svgr/webpack',
      options: {
        svgo: false,
      },
    },
  ],
};

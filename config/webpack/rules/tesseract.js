module.exports = {
  test: [
    /tesseract\.js\/dist\/worker\.min\.js$/,
    /tesseract\.js\/dist\/worker\.min\.js.map$/,
    /tesseract\.js-core\/tesseract-core\.wasm$/,
    /tesseract\.js-core\/tesseract-core\.wasm.js$/,
  ],
  use: {
    loader: 'file-loader',
    options: {
      name: 'ocr/[name]-[hash].[ext]',
    },
  },
};

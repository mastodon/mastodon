module.exports = {
  generator: {
    filename: 'ocr/[name]-[hash][ext]',
  },
  test: [
    /tesseract\.js\/dist\/worker\.min\.js$/,
    /tesseract\.js\/dist\/worker\.min\.js.map$/,
    /tesseract\.js-core\/tesseract-core\.wasm$/,
    /tesseract\.js-core\/tesseract-core\.wasm.js$/,
  ],
  type: 'asset/resource',
};

import EXIF from 'exif-js';

const MAX_IMAGE_PIXELS = 2073600; // 1920x1080px

const _browser_quirks = {};

// Some browsers will automatically draw images respecting their EXIF orientation
// while others won't, and the safest way to detect that is to examine how it
// is done on a known image.
// See https://github.com/w3c/csswg-drafts/issues/4666
// and https://github.com/blueimp/JavaScript-Load-Image/commit/1e4df707821a0afcc11ea0720ee403b8759f3881
const dropOrientationIfNeeded = (orientation) => new Promise(resolve => {
  switch (_browser_quirks['image-orientation-automatic']) {
  case true:
    resolve(1);
    break;
  case false:
    resolve(orientation);
    break;
  default:
    // black 2x1 JPEG, with the following meta information set:
    // - EXIF Orientation: 6 (Rotated 90° CCW)
    const testImageURL =
      'data:image/jpeg;base64,/9j/4QAiRXhpZgAATU0AKgAAAAgAAQESAAMAAAABAAYAAAA' +
      'AAAD/2wCEAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBA' +
      'QEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQE' +
      'BAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAf/AABEIAAEAAgMBEQACEQEDEQH/x' +
      'ABKAAEAAAAAAAAAAAAAAAAAAAALEAEAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAA' +
      'AAAAAEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwA/8H//2Q==';
    const img = new Image();
    img.onload = () => {
      const automatic = (img.width === 1 && img.height === 2);
      _browser_quirks['image-orientation-automatic'] = automatic;
      resolve(automatic ? 1 : orientation);
    };
    img.onerror = () => {
      _browser_quirks['image-orientation-automatic'] = false;
      resolve(orientation);
    };
    img.src = testImageURL;
  }
});

// Some browsers don't allow reading from a canvas and instead return all-white
// or randomized data. Use a pre-defined image to check if reading the canvas
// works.
const checkCanvasReliability = () => new Promise((resolve, reject) => {
  switch(_browser_quirks['canvas-read-unreliable']) {
  case true:
    reject('Canvas reading unreliable');
    break;
  case false:
    resolve();
    break;
  default:
    // 2×2 GIF with white, red, green and blue pixels
    const testImageURL =
      'data:image/gif;base64,R0lGODdhAgACAKEDAAAA//8AAAD/AP///ywAAAAAAgACAAACA1wEBQA7';
    const refData =
      [255, 255, 255, 255,  255, 0, 0, 255,  0, 255, 0, 255,  0, 0, 255, 255];
    const img = new Image();
    img.onload = () => {
      const canvas  = document.createElement('canvas');
      const context = canvas.getContext('2d');
      context.drawImage(img, 0, 0, 2, 2);
      const imageData = context.getImageData(0, 0, 2, 2);
      if (imageData.data.every((x, i) => refData[i] === x)) {
        _browser_quirks['canvas-read-unreliable'] = false;
        resolve();
      } else {
        _browser_quirks['canvas-read-unreliable'] = true;
        reject('Canvas reading unreliable');
      }
    };
    img.onerror = () => {
      _browser_quirks['canvas-read-unreliable'] = true;
      reject('Failed to load test image');
    };
    img.src = testImageURL;
  }
});

const getImageUrl = inputFile => new Promise((resolve, reject) => {
  if (window.URL && URL.createObjectURL) {
    try {
      resolve(URL.createObjectURL(inputFile));
    } catch (error) {
      reject(error);
    }
    return;
  }

  const reader = new FileReader();
  reader.onerror = (...args) => reject(...args);
  reader.onload  = ({ target }) => resolve(target.result);

  reader.readAsDataURL(inputFile);
});

const loadImage = inputFile => new Promise((resolve, reject) => {
  getImageUrl(inputFile).then(url => {
    const img = new Image();

    img.onerror = (...args) => reject(...args);
    img.onload  = () => resolve(img);

    img.src = url;
  }).catch(reject);
});

const getOrientation = (img, type = 'image/png') => new Promise(resolve => {
  if (type !== 'image/jpeg') {
    resolve(1);
    return;
  }

  EXIF.getData(img, () => {
    const orientation = EXIF.getTag(img, 'Orientation');
    if (orientation !== 1) {
      dropOrientationIfNeeded(orientation).then(resolve).catch(() => resolve(orientation));
    } else {
      resolve(orientation);
    }
  });
});

const processImage = (img, { width, height, orientation, type = 'image/png' }) => new Promise(resolve => {
  const canvas  = document.createElement('canvas');

  if (4 < orientation && orientation < 9) {
    canvas.width  = height;
    canvas.height = width;
  } else {
    canvas.width  = width;
    canvas.height = height;
  }

  const context = canvas.getContext('2d');

  switch (orientation) {
  case 2: context.transform(-1, 0, 0, 1, width, 0); break;
  case 3: context.transform(-1, 0, 0, -1, width, height); break;
  case 4: context.transform(1, 0, 0, -1, 0, height); break;
  case 5: context.transform(0, 1, 1, 0, 0, 0); break;
  case 6: context.transform(0, 1, -1, 0, height, 0); break;
  case 7: context.transform(0, -1, -1, 0, height, width); break;
  case 8: context.transform(0, -1, 1, 0, 0, width); break;
  }

  context.drawImage(img, 0, 0, width, height);

  canvas.toBlob(resolve, type);
});

const resizeImage = (img, type = 'image/png') => new Promise((resolve, reject) => {
  const { width, height } = img;

  const newWidth  = Math.round(Math.sqrt(MAX_IMAGE_PIXELS * (width / height)));
  const newHeight = Math.round(Math.sqrt(MAX_IMAGE_PIXELS * (height / width)));

  checkCanvasReliability()
    .then(getOrientation(img, type))
    .then(orientation => processImage(img, {
      width: newWidth,
      height: newHeight,
      orientation,
      type,
    }))
    .then(resolve)
    .catch(reject);
});

const WITHOUT_RESIZING_FORMATS = ['image/gif', 'image/heic', 'image/heif'];

export default inputFile => new Promise((resolve) => {
  if (!inputFile.type.match(/image.*/) || WITHOUT_RESIZING_FORMATS.indexOf(inputFile.type) >= 0) {
    resolve(inputFile);
    return;
  }

  loadImage(inputFile).then(img => {
    if (img.width * img.height < MAX_IMAGE_PIXELS) {
      resolve(inputFile);
      return;
    }

    resizeImage(img, inputFile.type)
      .then(resolve)
      .catch(() => resolve(inputFile));
  }).catch(() => resolve(inputFile));
});

import EXIF from 'exif-js';

const MAX_IMAGE_DIMENSION = 1280;

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
    resolve(orientation);
  });
});

const processImage = (img, { width, height, orientation, type = 'image/png' }) => new Promise(resolve => {
  const canvas  = document.createElement('canvas');
  [canvas.width, canvas.height] = orientation < 5 ? [width, height] : [height, width];

  const context = canvas.getContext('2d');

  switch (orientation) {
  case 2:
    context.translate(width, 0);
    break;
  case 3:
    context.translate(width, height);
    break;
  case 4:
    context.translate(0, height);
    break;
  case 5:
    context.rotate(0.5 * Math.PI);
    context.translate(1, -1);
    break;
  case 6:
    context.rotate(0.5 * Math.PI);
    context.translate(0, -height);
    break;
  case 7:
    context.rotate(0.5, Math.PI);
    context.translate(width, -height);
    break;
  case 8:
    context.rotate(-0.5, Math.PI);
    context.translate(-width, 0);
    break;
  }

  context.drawImage(img, 0, 0, width, height);

  canvas.toBlob(resolve, type);
});

const resizeImage = (img, type = 'image/png') => new Promise((resolve, reject) => {
  const { width, height } = img;

  let newWidth, newHeight;

  if (width > height) {
    newHeight = height * MAX_IMAGE_DIMENSION / width;
    newWidth  = MAX_IMAGE_DIMENSION;
  } else if (height > width) {
    newWidth  = width * MAX_IMAGE_DIMENSION / height;
    newHeight = MAX_IMAGE_DIMENSION;
  } else {
    newWidth  = MAX_IMAGE_DIMENSION;
    newHeight = MAX_IMAGE_DIMENSION;
  }

  getOrientation(img, type)
    .then(orientation => processImage(img, {
      width: newWidth,
      height: newHeight,
      orientation,
      type,
    }))
    .then(resolve)
    .catch(reject);
});

export default inputFile => new Promise((resolve, reject) => {
  if (!inputFile.type.match(/image.*/) || inputFile.type === 'image/gif') {
    resolve(inputFile);
    return;
  }

  loadImage(inputFile).then(img => {
    if (img.width < MAX_IMAGE_DIMENSION && img.height < MAX_IMAGE_DIMENSION) {
      resolve(inputFile);
      return;
    }

    resizeImage(img, inputFile.type)
      .then(resolve)
      .catch(() => resolve(inputFile));
  }).catch(reject);
});

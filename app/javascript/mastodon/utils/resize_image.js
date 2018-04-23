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

export default inputFile => new Promise((resolve, reject) => {
  if (!inputFile.type.match(/image.*/) || inputFile.type === 'image/gif') {
    resolve(inputFile);
    return;
  }

  loadImage(inputFile).then(img => {
    const canvas = document.createElement('canvas');
    const { width, height } = img;

    let newWidth, newHeight;

    if (width < MAX_IMAGE_DIMENSION && height < MAX_IMAGE_DIMENSION) {
      resolve(inputFile);
      return;
    }

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

    canvas.width  = newWidth;
    canvas.height = newHeight;

    canvas.getContext('2d').drawImage(img, 0, 0, newWidth, newHeight);

    canvas.toBlob(resolve, inputFile.type);
  }).catch(reject);
});

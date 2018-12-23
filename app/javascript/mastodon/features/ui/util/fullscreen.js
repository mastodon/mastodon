// APIs for normalizing fullscreen operations. Note that Edge uses
// the WebKit-prefixed APIs currently (as of Edge 16).

export const isFullscreen = () => document.fullscreenElement ||
  document.webkitFullscreenElement ||
  document.mozFullScreenElement;

export const exitFullscreen = () => {
  if (document.exitFullscreen) {
    document.exitFullscreen();
  } else if (document.webkitExitFullscreen) {
    document.webkitExitFullscreen();
  } else if (document.mozCancelFullScreen) {
    document.mozCancelFullScreen();
  }
};

export const requestFullscreen = el => {
  if (el.requestFullscreen) {
    el.requestFullscreen();
  } else if (el.webkitRequestFullscreen) {
    el.webkitRequestFullscreen();
  } else if (el.mozRequestFullScreen) {
    el.mozRequestFullScreen();
  }
};

export const attachFullscreenListener = (listener) => {
  if ('onfullscreenchange' in document) {
    document.addEventListener('fullscreenchange', listener);
  } else if ('onwebkitfullscreenchange' in document) {
    document.addEventListener('webkitfullscreenchange', listener);
  } else if ('onmozfullscreenchange' in document) {
    document.addEventListener('mozfullscreenchange', listener);
  }
};

export const detachFullscreenListener = (listener) => {
  if ('onfullscreenchange' in document) {
    document.removeEventListener('fullscreenchange', listener);
  } else if ('onwebkitfullscreenchange' in document) {
    document.removeEventListener('webkitfullscreenchange', listener);
  } else if ('onmozfullscreenchange' in document) {
    document.removeEventListener('mozfullscreenchange', listener);
  }
};

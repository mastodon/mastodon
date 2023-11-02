// APIs for normalizing fullscreen operations. Note that Edge uses
// the WebKit-prefixed APIs currently (as of Edge 16).

function lockLandscape() {
  if (screen.orientation && screen.orientation.lock) {
    screen.orientation.lock('landscape');
  }
}

function unlockLandscape() {
  if (screen.orientation && screen.orientation.lock) {
    screen.orientation.unlock();
  }
}

export const isFullscreen = () => document.fullscreenElement ||
  document.webkitFullscreenElement ||
  document.mozFullScreenElement;

export const exitFullscreen = () => {
  if (document.exitFullscreen) {
    unlockLandscape();
    document.exitFullscreen();
  } else if (document.webkitExitFullscreen) {
    unlockLandscape();
    document.webkitExitFullscreen();
  } else if (document.mozCancelFullScreen) {
    document.mozCancelFullScreen();
  }
};

export const requestFullscreen = el => {
  if (el.requestFullscreen) {
    el.requestFullscreen();
    lockLandscape();
  } else if (el.webkitRequestFullscreen) {
    el.webkitRequestFullscreen();
    lockLandscape();
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
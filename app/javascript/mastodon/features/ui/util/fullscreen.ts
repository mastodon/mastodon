/* eslint-disable @typescript-eslint/no-floating-promises */
/* eslint-disable @typescript-eslint/prefer-nullish-coalescing */
// APIs for normalizing fullscreen operations. Note that Edge uses
// the WebKit-prefixed APIs currently (as of Edge 16).

declare global {
  interface Document {
    mozCancelFullScreen?: (() => Promise<boolean>) | undefined;
    webkitExitFullscreen?: (() => Promise<boolean>) | undefined;
    mozFullScreenElement?: Element;
    webkitFullscreenElement?: Element;
  }

  interface Element {
    mozRequestFullScreen?: typeof Element.prototype.requestFullscreen;
    webkitRequestFullscreen?: typeof Element.prototype.requestFullscreen;
  }
}

export const isFullscreen = () =>
  document.fullscreenElement ||
  document.webkitFullscreenElement ||
  document.mozFullScreenElement;

export const exitFullscreen = () => {
  if (document.exitFullscreen as typeof document.exitFullscreen | undefined) {
    document.exitFullscreen();
  } else if (document.webkitExitFullscreen) {
    document.webkitExitFullscreen();
  } else if (document.mozCancelFullScreen) {
    document.mozCancelFullScreen();
  }
};

export const requestFullscreen = (el: Element) => {
  if (el.requestFullscreen as typeof el.requestFullscreen | undefined) {
    el.requestFullscreen();
  } else if (el.webkitRequestFullscreen) {
    el.webkitRequestFullscreen();
  } else if (el.mozRequestFullScreen) {
    el.mozRequestFullScreen();
  }
};

export const attachFullscreenListener = (listener: EventListener) => {
  if ('onfullscreenchange' in document) {
    document.addEventListener('fullscreenchange', listener);
  } else if ('onwebkitfullscreenchange' in document) {
    (document as Document).addEventListener('webkitfullscreenchange', listener);
  } else if ('onmozfullscreenchange' in document) {
    (document as Document).addEventListener('mozfullscreenchange', listener);
  }
};

export const detachFullscreenListener = (listener: EventListener) => {
  if ('onfullscreenchange' in document) {
    document.removeEventListener('fullscreenchange', listener);
  } else if ('onwebkitfullscreenchange' in document) {
    (document as Document).removeEventListener(
      'webkitfullscreenchange',
      listener,
    );
  } else if ('onmozfullscreenchange' in document) {
    (document as Document).removeEventListener('mozfullscreenchange', listener);
  }
};

// APIs for normalizing fullscreen operations. Note that Edge uses
// the WebKit-prefixed APIs currently (as of Edge 16).

interface DocumentWithFullscreen extends Document {
  mozFullScreenElement?: Element;
  webkitFullscreenElement?: Element;
  mozCancelFullScreen?: () => void;
  webkitExitFullscreen?: () => void;
}

interface HTMLElementWithFullscreen extends HTMLElement {
  mozRequestFullScreen?: () => void;
  webkitRequestFullscreen?: () => void;
}

export const isFullscreen = () => {
  const d = document as DocumentWithFullscreen;

  return !!(
    d.fullscreenElement ??
    d.webkitFullscreenElement ??
    d.mozFullScreenElement
  );
};

export const exitFullscreen = () => {
  const d = document as DocumentWithFullscreen;

  // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition
  if (d.exitFullscreen) {
    void d.exitFullscreen();
  } else if (d.webkitExitFullscreen) {
    d.webkitExitFullscreen();
  } else if (d.mozCancelFullScreen) {
    d.mozCancelFullScreen();
  }
};

export const requestFullscreen = (el: HTMLElementWithFullscreen | null) => {
  if (!el) {
    return;
  }

  // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition
  if (el.requestFullscreen) {
    void el.requestFullscreen();
  } else if (el.webkitRequestFullscreen) {
    el.webkitRequestFullscreen();
  } else if (el.mozRequestFullScreen) {
    el.mozRequestFullScreen();
  }
};

export const attachFullscreenListener = (listener: () => void) => {
  const d = document as DocumentWithFullscreen;

  if ('onfullscreenchange' in d) {
    d.addEventListener('fullscreenchange', listener);
  } else if ('onwebkitfullscreenchange' in d) {
    // @ts-expect-error This is valid on some browsers
    d.addEventListener('webkitfullscreenchange', listener); // eslint-disable-line @typescript-eslint/no-unsafe-call
  } else if ('onmozfullscreenchange' in d) {
    // @ts-expect-error This is valid on some browsers
    d.addEventListener('mozfullscreenchange', listener); // eslint-disable-line @typescript-eslint/no-unsafe-call
  }
};

export const detachFullscreenListener = (listener: () => void) => {
  const d = document as DocumentWithFullscreen;

  if ('onfullscreenchange' in d) {
    d.removeEventListener('fullscreenchange', listener);
  } else if ('onwebkitfullscreenchange' in d) {
    // @ts-expect-error This is valid on some browsers
    d.removeEventListener('webkitfullscreenchange', listener); // eslint-disable-line @typescript-eslint/no-unsafe-call
  } else if ('onmozfullscreenchange' in d) {
    // @ts-expect-error This is valid on some browsers
    d.removeEventListener('mozfullscreenchange', listener); // eslint-disable-line @typescript-eslint/no-unsafe-call
  }
};

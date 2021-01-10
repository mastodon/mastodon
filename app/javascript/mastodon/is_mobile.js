import { supportsPassiveEvents } from 'detect-passive-events';
import { forceSingleColumn } from 'mastodon/initial_state';

const LAYOUT_BREAKPOINT = 630;

export const isMobile = width => width <= LAYOUT_BREAKPOINT;

export const layoutFromWindow = () => {
  if (isMobile(window.innerWidth)) {
    return 'mobile';
  } else if (forceSingleColumn) {
    return 'single-column';
  } else {
    return 'multi-column';
  }
};

const iOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;

let userTouching = false;
let listenerOptions = supportsPassiveEvents ? { passive: true } : false;

const touchListener = () => {
  userTouching = true;
  window.removeEventListener('touchstart', touchListener, listenerOptions);
};

window.addEventListener('touchstart', touchListener, listenerOptions);

export const isUserTouching = () => userTouching;

export const isIOS = () => iOS;

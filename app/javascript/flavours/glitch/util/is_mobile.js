import { supportsPassiveEvents } from 'detect-passive-events';
import { forceSingleColumn } from 'flavours/glitch/util/initial_state';

const LAYOUT_BREAKPOINT = 630;

export function isMobile(width, columns) {
  switch (columns) {
  case 'multiple':
    return false;
  case 'single':
    return true;
  default:
    return forceSingleColumn || width <= LAYOUT_BREAKPOINT;
  }
};

const iOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;

let userTouching = false;
let listenerOptions = supportsPassiveEvents ? { passive: true } : false;

function touchListener() {
  userTouching = true;
  window.removeEventListener('touchstart', touchListener, listenerOptions);
}

window.addEventListener('touchstart', touchListener, listenerOptions);

export function isUserTouching() {
  return userTouching;
}

export function isIOS() {
  return iOS;
};

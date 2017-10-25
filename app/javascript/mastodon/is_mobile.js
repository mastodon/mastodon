import detectPassiveEvents from 'detect-passive-events';

const LAYOUT_BREAKPOINT = 630;

export function isMobile(width) {
  return width <= LAYOUT_BREAKPOINT;
};

const iOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;

let userTouching = false;
let listenerOptions = detectPassiveEvents.hasSupport ? { passive: true } : false;

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

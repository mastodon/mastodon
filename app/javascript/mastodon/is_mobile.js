// @ts-check

import { supportsPassiveEvents } from 'detect-passive-events';
// @ts-expect-error
import { forceSingleColumn } from 'mastodon/initial_state';

const LAYOUT_BREAKPOINT = 630;

/**
 * @param {number} width
 * @returns {boolean}
 */
export const isMobile = width => width <= LAYOUT_BREAKPOINT;

/**
 * @returns {string}
 */
export const layoutFromWindow = () => {
  if (isMobile(window.innerWidth)) {
    return 'mobile';
  } else if (forceSingleColumn) {
    return 'single-column';
  } else {
    return 'multi-column';
  }
};

// @ts-expect-error
const iOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;

const listenerOptions = supportsPassiveEvents ? { passive: true } : false;

let userTouching = false;

const touchListener = () => {
  userTouching = true;

  window.removeEventListener('touchstart', touchListener);
};

window.addEventListener('touchstart', touchListener, listenerOptions);

export const isUserTouching = () => userTouching;

export const isIOS = () => iOS;

// @ts-check

import { supportsPassiveEvents } from 'detect-passive-events';
import { forceSingleColumn } from 'flavours/glitch/initial_state';

const LAYOUT_BREAKPOINT = 630;

/**
 * @param {number} width
 * @returns {boolean}
 */
export const isMobile = width => width <= LAYOUT_BREAKPOINT;

/**
 * @param {string} layout_local_setting
 * @returns {string}
 */
export const layoutFromWindow = (layout_local_setting) => {
  switch (layout_local_setting) {
  case 'multiple':
    return 'multi-column';
  case 'single':
    if (isMobile(window.innerWidth)) {
      return 'mobile';
    } else {
      return 'single-column';
    }
  default:
    if (isMobile(window.innerWidth)) {
      return 'mobile';
    } else if (forceSingleColumn) {
      return 'single-column';
    } else {
      return 'multi-column';
    }
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

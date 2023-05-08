import { supportsPassiveEvents } from 'detect-passive-events';
import { forceSingleColumn } from './initial_state';

const LAYOUT_BREAKPOINT = 630;

export const isMobile = (width: number) => width <= LAYOUT_BREAKPOINT;

export type LayoutType = 'mobile' | 'single-column' | 'multi-column';
export const layoutFromWindow = (): LayoutType => {
  if (isMobile(window.innerWidth)) {
    return 'mobile';
  } else if (forceSingleColumn) {
    return 'single-column';
  } else {
    return 'multi-column';
  }
};

// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-expect-error
const iOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && window.MSStream != null;

const listenerOptions = supportsPassiveEvents ? { passive: true } : false;

let userTouching = false;

const touchListener = () => {
  userTouching = true;

  window.removeEventListener('touchstart', touchListener);
};

window.addEventListener('touchstart', touchListener, listenerOptions);

export const isUserTouching = () => userTouching;

export const isIOS = () => iOS;

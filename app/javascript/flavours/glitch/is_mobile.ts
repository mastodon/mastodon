import { supportsPassiveEvents } from 'detect-passive-events';
import { forceSingleColumn } from 'flavours/glitch/initial_state';

const LAYOUT_BREAKPOINT = 630;

export const isMobile = (width: number) => width <= LAYOUT_BREAKPOINT;

export type LayoutType = 'mobile' | 'single-column' | 'multi-column';
export const layoutFromWindow = (layout_local_setting : string): LayoutType => {
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

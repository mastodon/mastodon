const LAYOUT_BREAKPOINT = 1024;

export function isMobile(width) {
  return width <= LAYOUT_BREAKPOINT;
};

const iOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
let userTouching = false;

window.addEventListener('touchstart', () => {
  userTouching = true;
}, { once: true });

export function isUserTouching() {
  return userTouching;
}

export function isIOS() {
  return iOS;
};

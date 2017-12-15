import detectPassiveEvents from 'detect-passive-events';

const LAYOUT_BREAKPOINT = 630;

export function isMobile(width) {
  return width <= LAYOUT_BREAKPOINT;
};

const iOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;

// Last one checks for payload support: https://web-push-book.gauntface.com/chapter-06/01-non-standards-browsers/#no-payload
const pushNotifications = ('serviceWorker' in navigator && 'PushManager' in window && 'getKey' in PushSubscription.prototype);
const notifications = 'Notification' in window;

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

export function supportsPushNotifications() {
  return pushNotifications;
}

export function supportsNotifications() {
  return notifications;
}

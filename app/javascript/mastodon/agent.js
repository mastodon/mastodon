import detectPassiveEvents from 'detect-passive-events';

const LAYOUT_BREAKPOINT = 630;

export function isMobile(width) {
  return width <= LAYOUT_BREAKPOINT;
};

const Chrome = navigator.userAgent.includes('Chrome') && !window.MSStream;
const iOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;

let desktopNotifications = 'Notification' in window;

if (desktopNotifications && Chrome) {
  try {
    /*
       Issue 901843006: Allow the embedder to disable the Notification constructor.
       https://codereview.chromium.org/901843006
     */
    new Notification('', { silent: true, vibrate: true });
  } catch (error) {
    desktopNotifications = error.message !== 'Failed to construct \'Notification\': Illegal constructor. Use ServiceWorkerRegistration.showNotification() instead.';
  }
}

// Last one checks for payload support: https://web-push-book.gauntface.com/chapter-06/01-non-standards-browsers/#no-payload
const pushNotifications = ('serviceWorker' in navigator && 'PushManager' in window && 'getKey' in PushSubscription.prototype);

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

export function supportsDesktopNotifications() {
  return desktopNotifications;
}

export function supportsPushNotifications() {
  return pushNotifications;
}

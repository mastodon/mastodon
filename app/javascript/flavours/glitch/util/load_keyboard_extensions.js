// On KaiOS, we may not be able to use a mouse cursor or navigate using Tab-based focus, so we install
// special left/right focus navigation keyboard listeners, at least on public pages (i.e. so folks
// can at least log in using KaiOS devices).

function importArrowKeyNavigation() {
  return import(/* webpackChunkName: "arrow-key-navigation" */ 'arrow-key-navigation');
}

export default function loadKeyboardExtensions() {
  if (/KAIOS/.test(navigator.userAgent)) {
    return importArrowKeyNavigation().then(arrowKeyNav => {
      arrowKeyNav.register();
    });
  }
  return Promise.resolve();
}

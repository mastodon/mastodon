//  Package imports.
import detectPassiveEvents from 'detect-passive-events';

//  This will either be a passive lister options object (if passive
//  events are supported), or `false`.
export const withPassive = detectPassiveEvents.hasSupport ? { passive: true } : false;

//  Focuses the root element.
export function focusRoot () {
  let e;
  if (document && (e = document.querySelector('.ui')) && (e = e.parentElement)) {
    e.focus();
  }
}

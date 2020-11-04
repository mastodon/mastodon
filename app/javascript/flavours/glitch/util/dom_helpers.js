//  Package imports.
import { supportsPassiveEvents } from 'detect-passive-events';

//  This will either be a passive lister options object (if passive
//  events are supported), or `false`.
export const withPassive = supportsPassiveEvents ? { passive: true } : false;

//  Focuses the root element.
export function focusRoot () {
  let e;
  if (document && (e = document.querySelector('.ui')) && (e = e.parentElement)) {
    e.focus();
  }
}

//  Package imports.
import detectPassiveEvents from 'detect-passive-events';

//  This will either be a passive lister options object (if passive
//  events are supported), or `false`.
export const withPassive = detectPassiveEvents.hasSupport ? { passive: true } : false;

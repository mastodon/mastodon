import { isImmutable } from 'immutable';

/**
 * Converts an immutable Map or Set to JS if it isn't already a plain JS object.
 * This is useful in code that needs to be able to deal with either type.
 */

export function immutableToJSIfNeeded<T>(object: T): T {
  return isImmutable(object) ? (object.toJS() as T) : object;
}

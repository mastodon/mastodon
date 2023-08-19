import { fromJS } from 'immutable';
import type { Map } from 'immutable';

// TypeSafeImmutableCollection is an immutable map whose get() function is correctly typed for any type of T, where T is an object.
//
// The primary way to create one of these is using intoTypeSafeImmutableMap.
//
export interface TypeSafeImmutableMap<T extends object>
  extends Map<keyof T, unknown> {
  get<K extends keyof T, V extends T[K] | null | undefined = undefined>(
    key: K,
    notSetValue?: V
  ): V;
}

// TODO(trinitroglycerin): This is NOT typed correctly for nested collections.
//
// fromJS(T) will take a T and turn any nested collections into List() or Map() as appropriate, however
// the typing of this function implies that arrays and objects are untouched.
//
// This could be fixed using Pick and generics, maybe.
export function intoTypeSafeImmutableMap<T extends object>(
  t: T
): TypeSafeImmutableMap<T> {
  return fromJS(t);
}

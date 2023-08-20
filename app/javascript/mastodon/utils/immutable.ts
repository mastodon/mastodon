import { fromJS } from 'immutable';
import type { List } from 'immutable';

type IsPrimitive<T> = T extends number | string | boolean | symbol ? T : never;

type IsObjectButNotArray<T> = T extends {
  [key: string]: unknown;
  length?: never;
}
  ? T
  : never;

type IsArray<T> = T extends { [key: number]: unknown; length: number }
  ? T
  : never;

type KeysThatAreObjects<T> = {
  [K in keyof T]: T[K] extends IsObjectButNotArray<T[K]> ? K : never;
}[keyof T];

type KeysThatAreArrays<T> = {
  [K in keyof T]: T[K] extends IsArray<T[K]> ? K : never;
}[keyof T];

type KeysThatArePrimitives<T> = {
  [K in keyof T]: T[K] extends IsPrimitive<T[K]> ? K : never;
}[keyof T];

// TypeSafeImmutableMap is an immutable map whose get() function is correctly typed for any type of T, where T is an object.
//
// The primary way to create one of these is using intoTypeSafeImmutableMap.
//
// This is a union type to permit TypeSafeImmutableMap having signatures that diverge from the signatures in the immutable typings.
//
// This a very gnarly interface that gives us recursive, correctly typed immutable maps at the cost of us having to explicitly type each method from Immutable we want to use.
export interface Map<T extends object> {
  // This must be first, otherwise strings will not be handled correctly and will be assumed to be lists.
  get<K extends KeysThatArePrimitives<T>>(val: K): T[K];
  get<K extends KeysThatAreArrays<T>>(val: K): List<Map<T>>;
  get<K extends KeysThatAreObjects<T>>(val: K): Map<T[K]>;
  update<K extends keyof T>(key: K, updater: (current: T[K]) => T[K]): this;
  merge<TValue extends object, TOther extends Map<TValue>>(
    other: TOther
  ): Map<T & TValue>;

  withMutations<V extends object>(updater: (me: Map<V>) => void): Map<V>;
  set<K extends keyof T>(key: K, val: T[K]): this;
}

export function intoTypeSafeImmutableMap<T extends object>(t: T): Map<T> {
  return fromJS(t) as unknown as Map<T>;
}

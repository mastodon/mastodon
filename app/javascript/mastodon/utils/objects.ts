import { isPlainObject } from '@reduxjs/toolkit';

import type { Get, IsUnknown, UnknownRecord } from 'type-fest';

export function isRecordObject(obj: unknown): obj is UnknownRecord {
  return isPlainObject(obj);
}

type NestedProperty<TObject, TKeys extends readonly string[]> =
  IsUnknown<TObject> extends true
    ? unknown
    : IsUnknown<Get<TObject, TKeys>> extends true
      ? undefined
      : Get<TObject, TKeys>;

export function getNestedProperty<TObject>(object: TObject): TObject;
export function getNestedProperty<
  TObject,
  const TKeys extends readonly string[],
>(object: TObject, ...keys: TKeys): NestedProperty<TObject, TKeys>;
export function getNestedProperty(object: unknown, ...keys: readonly string[]) {
  if (keys.length === 0) {
    return object;
  }

  let currentValue = object;

  for (const key of keys) {
    if (!isRecordObject(currentValue) || !(key in currentValue)) {
      return undefined;
    }

    currentValue = currentValue[key];
  }

  return currentValue;
}

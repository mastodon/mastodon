import { isPlainObject } from '@reduxjs/toolkit';

export type RecordObject = Record<PropertyKey, unknown>;

export function isRecordObject(obj: unknown): obj is RecordObject {
  return isPlainObject(obj);
}

type NestedProperty<T, K extends readonly PropertyKey[]> = K extends readonly [
  infer Head,
  ...infer Tail,
]
  ? Head extends keyof NonNullable<T>
    ? Tail extends readonly PropertyKey[]
      ? NestedProperty<NonNullable<T>[Head], Tail>
      : NonNullable<T>[Head]
    : undefined
  : T;

export function getNestedProperty<
  TObject extends RecordObject,
  const TKeys extends readonly PropertyKey[],
>(object: TObject, ...keys: TKeys): NestedProperty<TObject, TKeys> | undefined;
export function getNestedProperty(
  object: unknown,
  ...keys: PropertyKey[]
): unknown;
export function getNestedProperty(
  object: unknown,
  ...keys: PropertyKey[]
): unknown {
  if (!isRecordObject(object) || keys.length === 0) {
    return undefined;
  }

  const remainingKeys = [...keys];
  let currentObject: RecordObject = object;
  while (remainingKeys.length > 0) {
    const currentKey = remainingKeys.shift();
    if (currentKey !== undefined && currentKey in currentObject) {
      const nextObject = currentObject[currentKey];
      if (isRecordObject(nextObject)) {
        currentObject = nextObject;
        continue;
      } else if (remainingKeys.length === 0) {
        return nextObject;
      }
    }
  }

  return undefined;
}

/* eslint-disable @typescript-eslint/no-confusing-void-expression */
import { getNestedProperty } from './objects';

describe('getNestedProperty', () => {
  const obj = { a: { b: { c: 42 } } } as const;

  test('returns the value of a nested property if it exists', () => {
    expect(getNestedProperty(obj, 'a', 'b', 'c')).toBe(42);
  });

  test('returns undefined if any part of the path does not exist', () => {
    expect(getNestedProperty(obj, 'a', 'x', 'c')).toBeUndefined();
    expect(getNestedProperty(obj, 'a', 'b', 'x')).toBeUndefined();
    expect(getNestedProperty(obj, 'x', 'b', 'c')).toBeUndefined();
  });

  test('returns undefined if the initial object is not a record', () => {
    expect(getNestedProperty(null, 'a', 'b')).toBeUndefined();
    expect(getNestedProperty(42, 'a', 'b')).toBeUndefined();
    expect(getNestedProperty('string', 'a', 'b')).toBeUndefined();
  });

  test('returns the object if no keys are provided', () => {
    expect(getNestedProperty({ a: 1 })).toStrictEqual({ a: 1 });
  });
});

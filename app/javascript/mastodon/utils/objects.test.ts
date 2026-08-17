/* eslint-disable @typescript-eslint/no-confusing-void-expression */
import { getNestedProperty } from './objects';

describe('getNestedProperty', () => {
  test('returns the value of a nested property if it exists', () => {
    const obj = { a: { b: { c: 42 } } };
    expect(getNestedProperty(obj, 'a', 'b', 'c')).toBe(42);
  });

  test('returns undefined if any part of the path does not exist', () => {
    const obj = { a: { b: { c: 42 } } };
    expect(getNestedProperty(obj, 'a', 'x', 'c')).toBeUndefined();
    expect(getNestedProperty(obj, 'a', 'b', 'x')).toBeUndefined();
    expect(getNestedProperty(obj, 'x', 'b', 'c')).toBeUndefined();
  });

  test('returns undefined if the initial object is not a record', () => {
    expect(getNestedProperty(null, 'a', 'b')).toBeUndefined();
    expect(getNestedProperty(42, 'a', 'b')).toBeUndefined();
    expect(getNestedProperty('string', 'a', 'b')).toBeUndefined();
  });

  test('returns undefined if no keys are provided', () => {
    const obj = { a: 1 };
    expect(getNestedProperty(obj)).toBeUndefined();
  });
});

/**
 * Splits a long array so that the resulting nested arrays
 * never exceed the `maxLength` provided.
 * Useful when dealing with endpoints that accept a limited number
 * of parameters
 */
export function batchArray<T>(array: T[], maxLength: number) {
  const result: T[][] = [];

  for (let i = 0; i < array.length; i += maxLength) {
    result.push(array.slice(i, i + maxLength));
  }

  return result;
}

/**
 * Returns the input if it is a string, otherwise returns undefined.
 * @param input Any input.
 * @returns The string, or undefined.
 */
export function stringOrUndefined(input: unknown) {
  return typeof input === 'string' ? input : undefined;
}

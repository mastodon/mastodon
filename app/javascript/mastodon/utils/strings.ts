/**
 * Returns the input if it is a string, otherwise returns undefined.
 * @param input Any input.
 * @returns The string, or undefined.
 */
export function stringOrUndefined(input: unknown) {
  return typeof input === 'string' ? input : undefined;
}

/**
 * Extracts a file name from a URL.
 * @param url The URL to extract the filename from.
 */
export function fileName(url: string) {
  return url.split('/').pop()?.split('#')[0]?.split('?')[0];
}

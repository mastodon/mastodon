export function isValidUrl(
  url: string,
  allowedProtocols = ['https:'],
): boolean {
  try {
    const parsedUrl = new URL(url);
    return allowedProtocols.includes(parsedUrl.protocol);
  } catch {
    return false;
  }
}

/**
 * Checks if the input string is probably a URL without a protocol. Note this is not full URL validation,
 * and is mostly used to detect link-like inputs.
 * @see https://www.xjavascript.com/blog/check-if-a-javascript-string-is-a-url/
 * @param input The input string to check
 */
export function isUrlWithoutProtocol(input: string): boolean {
  if (!input.length || input.includes(' ') || input.includes('://')) {
    return false;
  }

  try {
    const url = new URL(`http://${input}`);
    const { host } = url;
    return (
      host !== '' && // Host is not empty
      host.includes('.') && // Host contains at least one dot
      !host.endsWith('.') && // No trailing dot
      !host.includes('..') && // No consecutive dots
      /\.[\w]{2,}$/.test(host) // TLD is at least 2 characters
    );
  } catch {}

  return false;
}

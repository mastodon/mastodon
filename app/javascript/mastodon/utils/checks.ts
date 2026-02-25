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

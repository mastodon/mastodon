export function uuid(): string {
  // Create an array of 16 bytes
  const bytes = new Uint8Array(16);
  window.crypto.getRandomValues(bytes);

  // Per RFC4122, set bits for version and `clock_seq_hi_and_reserved`
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // Version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variant 10

  // Convert bytes to UUID string
  return (
    bytes.slice(0, 4).map(b => b.toString(16).padStart(2, '0')).join('') + '-' +
    bytes.slice(4, 6).map(b => b.toString(16).padStart(2, '0')).join('') + '-' +
    bytes.slice(6, 8).map(b => b.toString(16).padStart(2, '0')).join('') + '-' +
    bytes.slice(8, 10).map(b => b.toString(16).padStart(2, '0')).join('') + '-' +
    bytes.slice(10, 16).map(b => b.toString(16).padStart(2, '0')).join('')
  );
}

export function uuid(a?: string): string {
  // Use the platform crypto where available. Prefer crypto.randomUUID() when generating
  // a full UUID, otherwise fall back to a secure getRandomValues-based generator used
  // as the replace callback. This avoids using Math.random() entirely.
  const cryptoObj =
    (typeof globalThis !== 'undefined' && (globalThis as any).crypto) ||
    (typeof window !== 'undefined' && (window as any).crypto);

  if (!cryptoObj || typeof cryptoObj.getRandomValues !== 'function') {
    throw new Error(
      'Secure crypto.getRandomValues is not available in this environment. UUID generation requires a secure crypto source.'
    );
  }

  // Called as the replacer function from String.replace (a is the matched char)
  if (a) {
    const rnd = cryptoObj.getRandomValues(new Uint8Array(1))[0] & 15;
    return (Number(a) ^ (rnd >> (Number(a) / 4))).toString(16);
  }

  // Called with no args: generate a full UUID.
  // Prefer native crypto.randomUUID() when available for simplicity and correctness.
  if (typeof (cryptoObj as any).randomUUID === 'function') {
    return (cryptoObj as any).randomUUID();
  }

  // eslint-disable-next-line @typescript-eslint/restrict-plus-operands
  return ('' + 1e7 + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, uuid);
}

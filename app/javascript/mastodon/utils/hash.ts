/**
 * Fast insecure hash function.
 * @param str String to hash.
 * @param seed Optional seed value for different hash outputs of the same string.
 * @returns Base-36 hash (1-6 characters, typically 5-6).
 */
export function cyrb32(str: string, seed = 0) {
  let h1 = 0xdeadbeef ^ seed;
  for (let i = 0; i < str.length; i++) {
    h1 = Math.imul(h1 ^ str.charCodeAt(i), 0x9e3779b1);
  }
  return ((h1 ^ (h1 >>> 16)) >>> 0).toString(36);
}

/**
 * Hashes an array of objects into a new array where each object has a unique hash key.
 * @param array Array of objects to hash.
 * @param key Key name to use for the hash in the resulting objects (default: 'id').
 */
export function hashObjectArray<
  TObj extends object,
  TKey extends string = 'id',
>(array: TObj[], key = 'id' as TKey): (TObj & Record<TKey, string>)[] {
  const keySet = new Set<string>();

  return array.map((obj) => {
    const json = JSON.stringify(obj);
    let seed = 0;
    let hash = cyrb32(json, seed);
    while (keySet.has(hash)) {
      hash = cyrb32(json, ++seed);
    }
    keySet.add(hash);
    return {
      ...obj,
      [key]: hash,
    } as TObj & Record<TKey, string>;
  });
}

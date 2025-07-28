interface CacheReturn<CacheKey, CacheValue> {
  has: (key: CacheKey) => boolean;
  get: (key: CacheKey) => CacheValue | undefined;
  delete: (key: CacheKey) => void;
  set: (key: CacheKey, value: CacheValue) => void;
}

export function createCache<CacheValue, CacheKey = string>(
  maxSize = 100,
): CacheReturn<CacheKey, CacheValue> {
  const cacheMap = new Map<CacheKey, CacheValue>();
  const cacheKeys = new Set<CacheKey>();

  function touchKey(key: CacheKey) {
    if (cacheKeys.has(key)) {
      cacheKeys.delete(key);
    }
    cacheKeys.add(key);
  }

  return {
    has: (key) => cacheMap.has(key),
    get: (key) => {
      if (cacheMap.has(key)) {
        touchKey(key);
      }
      return cacheMap.get(key);
    },
    delete: (key) => cacheMap.delete(key) && cacheKeys.delete(key),
    set: (key, value) => {
      cacheMap.set(key, value);
      touchKey(key);

      const lastKey = cacheKeys.values().toArray().shift();
      if (cacheMap.size > maxSize && lastKey) {
        cacheMap.delete(lastKey);
        cacheKeys.delete(lastKey);
      }
    },
  };
}

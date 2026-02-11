import { useCallback, useMemo } from 'react';

export function useStorage({
  type = 'local',
  prefix = '',
}: { type?: 'local' | 'session'; prefix?: string } = {}) {
  const storageType = type === 'local' ? 'localStorage' : 'sessionStorage';
  const isAvailable = useMemo(
    () => storageAvailable(storageType),
    [storageType],
  );

  const getItem = useCallback(
    (key: string) => {
      if (!isAvailable) {
        return null;
      }
      try {
        return window[storageType].getItem(prefix ? `${prefix};${key}` : key);
      } catch {
        return null;
      }
    },
    [isAvailable, storageType, prefix],
  );
  const setItem = useCallback(
    (key: string, value: string) => {
      if (!isAvailable) {
        return;
      }
      try {
        window[storageType].setItem(prefix ? `${prefix};${key}` : key, value);
      } catch {}
    },
    [isAvailable, storageType, prefix],
  );

  return {
    isAvailable,
    getItem,
    setItem,
  };
}

// Tests the storage availability for the given type. Taken from MDN:
// https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API/Using_the_Web_Storage_API
export function storageAvailable(type: 'localStorage' | 'sessionStorage') {
  let storage;
  try {
    storage = window[type];
    const x = '__storage_test__';
    storage.setItem(x, x);
    storage.removeItem(x);
    return true;
  } catch (e) {
    return (
      e instanceof DOMException &&
      e.name === 'QuotaExceededError' &&
      // acknowledge QuotaExceededError only if there's something already stored
      storage &&
      storage.length !== 0
    );
  }
}

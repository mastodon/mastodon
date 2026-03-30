import { useCallback, useMemo, useState } from 'react';

interface StorageOptions {
  type?: 'local' | 'session';
  prefix?: string;
}

export function useStorage({
  type = 'local',
  prefix = '',
}: StorageOptions = {}) {
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

  const removeItem = useCallback(
    (key: string) => {
      if (!isAvailable) {
        return;
      }
      try {
        window[storageType].removeItem(prefix ? `${prefix};${key}` : key);
      } catch {}
    },
    [isAvailable, storageType, prefix],
  );

  return {
    isAvailable,
    getItem,
    setItem,
    removeItem,
  };
}

export function useStorageState<T extends string | boolean>(
  key: string,
  initialState: T,
  options?: StorageOptions,
) {
  const { getItem, setItem, removeItem } = useStorage(options);
  const [state, setState] = useState<T>(
    () => (retrieveBooleanOrString(getItem(key)) as T | null) ?? initialState,
  );

  const handleSetState = useCallback(
    (newValue: T) => {
      setItem(key, castToString(newValue));
      setState(newValue);
    },
    [key, setItem],
  );

  const removeState = useCallback(() => {
    removeItem(key);
    setState(initialState);
  }, [initialState, key, removeItem]);

  return [state, handleSetState, removeState] as const;
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

function castToString(value: string | boolean) {
  if (typeof value === 'boolean') {
    return value ? '1' : '0';
  } else {
    return value;
  }
}

function retrieveBooleanOrString(value: string | null) {
  if (value === '1') {
    return true;
  } else if (value === '0') {
    return false;
  } else {
    return value;
  }
}

import { useRef, useEffect } from 'react';

/**
 * Returns the previous state of the passed in value.
 * On first render, undefined is returned.
 */

export function usePrevious<T>(value: T): T | undefined {
  const ref = useRef<T>();

  useEffect(() => {
    ref.current = value;
  }, [value]);

  return ref.current;
}

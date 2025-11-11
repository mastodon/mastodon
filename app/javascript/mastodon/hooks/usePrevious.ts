import { useState } from 'react';

/**
 * Returns the previous state of the passed in value.
 * On first render, undefined is returned.
 */

export function usePrevious<T>(value: T): T | undefined {
  const [{ previous, current }, setMemory] = useState<{
    previous: T | undefined;
    current: T;
  }>(() => ({ previous: undefined, current: value }));

  let result = previous;

  if (value !== current) {
    setMemory({
      previous: current,
      current: value,
    });
    // Ensure that the returned result updates synchronously
    result = current;
  }

  return result;
}

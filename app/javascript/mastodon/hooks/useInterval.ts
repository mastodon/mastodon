import { useEffect, useLayoutEffect, useRef } from 'react';

/**
 * Hook to create an interval that invokes a callback function
 * at a specified delay using the setInterval API.
 * Based on https://usehooks-ts.com/react-hook/use-interval
 */
export function useInterval(
  callback: () => void,
  {
    delay,
    isEnabled = true,
  }: {
    delay: number;
    isEnabled?: boolean;
  },
) {
  const savedCallback = useRef(callback);

  // Remember the latest callback if it changes.
  useLayoutEffect(() => {
    savedCallback.current = callback;
  }, [callback]);

  // Set up the interval.
  useEffect(() => {
    // Don't schedule if no delay is specified.
    // Note: 0 is a valid value for delay.
    if (!isEnabled) {
      return;
    }

    const id = setInterval(() => {
      savedCallback.current();
    }, delay);

    return () => {
      clearInterval(id);
    };
  }, [delay, isEnabled]);
}

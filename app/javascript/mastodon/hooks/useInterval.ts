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
  // Write callback to a ref so we can omit it from
  // the interval effect's dependency array
  const callbackRef = useRef(callback);
  useLayoutEffect(() => {
    callbackRef.current = callback;
  }, [callback]);

  // Set up the interval.
  useEffect(() => {
    if (!isEnabled) {
      return;
    }

    const intervalId = setInterval(() => {
      callbackRef.current();
    }, delay);

    return () => {
      clearInterval(intervalId);
    };
  }, [delay, isEnabled]);
}

import { useRef, useCallback, useEffect } from 'react';

export const useTimeout = () => {
  const timeoutRef = useRef<ReturnType<typeof setTimeout>>();

  const set = useCallback((callback: () => void, delay: number) => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    timeoutRef.current = setTimeout(callback, delay);
  }, []);

  const cancel = useCallback(() => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
      timeoutRef.current = undefined;
    }
  }, []);

  useEffect(
    () => () => {
      cancel();
    },
    [cancel],
  );

  return [set, cancel] as const;
};

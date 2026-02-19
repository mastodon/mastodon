import { useRef, useCallback, useEffect } from 'react';

export const useTimeout = () => {
  const timeoutRef = useRef<ReturnType<typeof setTimeout>>();
  const callbackRef = useRef<() => void>();

  const set = useCallback((callback: () => void, delay: number) => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    callbackRef.current = callback;
    timeoutRef.current = setTimeout(callback, delay);
  }, []);

  const delay = useCallback((delay: number) => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    if (!callbackRef.current) {
      return;
    }

    timeoutRef.current = setTimeout(callbackRef.current, delay);
  }, []);

  const cancel = useCallback(() => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
      timeoutRef.current = undefined;
      callbackRef.current = undefined;
    }
  }, []);

  useEffect(
    () => () => {
      cancel();
    },
    [cancel],
  );

  return [set, cancel, delay] as const;
};

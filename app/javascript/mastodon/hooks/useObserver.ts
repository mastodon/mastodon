import { useEffect, useRef } from 'react';

export function useResizeObserver(callback: ResizeObserverCallback) {
  const observerRef = useRef<ResizeObserver>(null);
  observerRef.current ??= new ResizeObserver(callback);

  useEffect(() => {
    const observer = observerRef.current;
    return () => {
      observer?.disconnect();
    };
  }, []);

  return observerRef.current;
}

export function useMutationObserver(callback: MutationCallback) {
  const observerRef = useRef<MutationObserver>(null);
  observerRef.current ??= new MutationObserver(callback);

  useEffect(() => {
    const observer = observerRef.current;
    return () => {
      observer?.disconnect();
    };
  }, []);

  return observerRef.current;
}

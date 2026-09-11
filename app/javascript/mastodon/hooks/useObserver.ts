import { useEffect, useState } from 'react';

export function useResizeObserver(callback: ResizeObserverCallback) {
  const [observer] = useState(() => new ResizeObserver(callback));

  useEffect(() => {
    return () => {
      observer.disconnect();
    };
  }, [observer]);

  return observer;
}

export function useMutationObserver(callback: MutationCallback) {
  const [observer] = useState(() => new MutationObserver(callback));

  useEffect(() => {
    return () => {
      observer.disconnect();
    };
  }, [observer]);

  return observer;
}

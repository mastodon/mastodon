import type { RefCallback } from 'react';
import { useCallback, useEffect, useMemo, useState } from 'react';

export function useVisibility({
  observerOptions,
}: {
  observerOptions?: IntersectionObserverInit;
} = {}) {
  const [isIntersecting, setIsIntersecting] = useState(false);
  const handleIntersect: IntersectionObserverCallback = useCallback(
    (entries) => {
      const entry = entries.at(0);
      if (!entry) {
        return;
      }

      setIsIntersecting(entry.isIntersecting);
    },
    [],
  );
  const observer = useMemo(
    () => new IntersectionObserver(handleIntersect, observerOptions),
    [handleIntersect, observerOptions],
  );

  const handleObserverRef: RefCallback<HTMLElement> = useCallback(
    (node) => {
      if (node) {
        observer.observe(node);
      }
    },
    [observer],
  );

  useEffect(() => {
    return () => {
      observer.disconnect();
    };
  }, [observer]);

  return {
    isIntersecting,
    observedRef: handleObserverRef,
  };
}

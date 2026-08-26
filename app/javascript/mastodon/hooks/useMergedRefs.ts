import { useCallback } from 'react';

export function useMergedRefs<T>(...refs: (React.Ref<T> | undefined)[]) {
  const setRef: React.RefCallback<T> = useCallback(
    (node: T | null) => {
      const cleanups: (() => void)[] = [];
      for (const ref of refs) {
        if (typeof ref === 'function') {
          const cleanup = ref(node);
          if (cleanup) {
            cleanups.push(cleanup);
          }
        } else if (ref) {
          // eslint-disable-next-line react-hooks/immutability -- Refs can be mutated
          ref.current = node;
        }
      }

      return () => {
        for (const cleanup of cleanups) {
          cleanup();
        }
      };
    },
    [refs],
  );
  // eslint-disable-next-line react-hooks/immutability
  return setRef;
}

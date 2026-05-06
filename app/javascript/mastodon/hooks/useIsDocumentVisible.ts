import { useEffect, useRef, useState } from 'react';

export function useIsDocumentVisible({
  onChange,
}: {
  onChange?: (isVisible: boolean) => void;
} = {}) {
  const [isDocumentVisible, setIsDocumentVisible] = useState(
    () => document.visibilityState === 'visible',
  );

  const onChangeRef = useRef(onChange);
  useEffect(() => {
    onChangeRef.current = onChange;
  }, [onChange]);

  useEffect(() => {
    function handleVisibilityChange() {
      const isVisible = document.visibilityState === 'visible';

      setIsDocumentVisible(isVisible);
      onChangeRef.current?.(isVisible);
    }
    window.addEventListener('visibilitychange', handleVisibilityChange);

    return () => {
      window.removeEventListener('visibilitychange', handleVisibilityChange);
    };
  }, []);

  return isDocumentVisible;
}

import { useEffect } from 'react';

export function usePreventClosingPage(shouldPreventClosing: boolean) {
  useEffect(() => {
    function closePage(event: BeforeUnloadEvent) {
      if (shouldPreventClosing) {
        event.preventDefault();
        return true;
      }
      return;
    }

    window.addEventListener('beforeunload', closePage);
    return () => {
      window.removeEventListener('beforeunload', closePage);
    };
  }, [shouldPreventClosing]);
}

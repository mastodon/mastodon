import { useCallback, useEffect, useState } from 'react';

interface Size {
  width: number;
  height: number;
}

export function getViewportSize(): Size {
  if (window.visualViewport) {
    return {
      width: window.visualViewport.width,
      height: window.visualViewport.height,
    };
  }

  return {
    width: window.innerWidth,
    height: window.innerHeight,
  };
}

/**
 * Returns the viewport size. This can also be used as a dependency in a
 * useEffect to trigger an update when the browser resizes.
 *
 * Based on https://martijnhols.nl/blog/how-to-get-document-height-ios-safari-osk
 */
export function useViewportSize() {
  const [viewportSize, setViewportSize] = useState(getViewportSize);
  const updateViewportSize = useCallback(() => {
    const viewportSize = getViewportSize();

    setViewportSize((oldViewportSize) => {
      if (
        oldViewportSize.width === viewportSize.width &&
        oldViewportSize.height === viewportSize.height
      ) {
        return oldViewportSize;
      }

      return viewportSize;
    });
  }, []);

  useEffect(() => {
    const effectTwice = () => {
      updateViewportSize();
      setTimeout(updateViewportSize, 1000);
    };

    window.addEventListener('resize', effectTwice);
    window.addEventListener('orientationchange', effectTwice);
    window.visualViewport?.addEventListener('resize', effectTwice);

    return () => {
      window.removeEventListener('resize', effectTwice);
      window.removeEventListener('orientationchange', effectTwice);
      window.visualViewport?.removeEventListener('resize', effectTwice);
    };
  }, [updateViewportSize]);

  return viewportSize;
}

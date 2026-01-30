import { useState, useRef, useCallback, useEffect } from 'react';

/**
 * Calculate and manage overflow of child elements within a container.
 *
 * To use, wire up the `wrapperRef` to the container element, and the `listRef` to the
 * child element that contains the items to be measured. If autoResize is true,
 * the list element will have its max-width set to prevent wrapping. The listRef element
 * requires both position:relative and overflow:hidden styles to work correctly.
 */
export function useOverflow({
  autoResize,
  padding = 4,
}: { autoResize?: boolean; padding?: number } = {}) {
  const [hiddenIndex, setHiddenIndex] = useState(-1);
  const [hiddenCount, setHiddenCount] = useState(0);
  const [maxWidth, setMaxWidth] = useState<number | 'none'>('none');

  // This is the item container element.
  const listRef = useRef<HTMLElement | null>(null);

  // The main recalculation function.
  const handleRecalculate = useCallback(() => {
    const listEle = listRef.current;
    if (!listEle) return;

    const reset = () => {
      setHiddenIndex(-1);
      setHiddenCount(0);
      setMaxWidth('none');
    };

    // Calculate the width via the parent element, minus the more button, minus the padding.
    const maxWidth =
      (listEle.parentElement?.offsetWidth ?? 0) -
      (listEle.nextElementSibling?.scrollWidth ?? 0) -
      padding;
    if (maxWidth <= 0) {
      reset();
      return;
    }

    // Iterate through children until we exceed max width.
    let visible = 0;
    let index = 0;
    let totalWidth = 0;
    for (const child of listEle.children) {
      if (child instanceof HTMLElement) {
        const rightOffset = child.offsetLeft + child.offsetWidth;
        if (rightOffset <= maxWidth) {
          visible += 1;
          totalWidth = rightOffset;
        } else {
          break;
        }
      }
      index++;
    }

    // All are visible, so remove max-width restriction.
    if (visible === listEle.children.length) {
      reset();
      return;
    }

    // Set the width to avoid wrapping, and set hidden count.
    setHiddenIndex(index);
    setHiddenCount(listEle.children.length - visible);
    setMaxWidth(totalWidth);
  }, [padding]);

  useEffect(() => {
    if (listRef.current && autoResize) {
      listRef.current.style.maxWidth =
        typeof maxWidth === 'number' ? `${maxWidth}px` : maxWidth;
    }
  }, [autoResize, maxWidth]);

  // Set up observers to watch for size and content changes.
  const resizeObserverRef = useRef<ResizeObserver | null>(null);
  const mutationObserverRef = useRef<MutationObserver | null>(null);

  // Helper to get or create the resize observer.
  const resizeObserver = useCallback(() => {
    const observer = (resizeObserverRef.current ??= new ResizeObserver(
      handleRecalculate,
    ));
    return observer;
  }, [handleRecalculate]);

  // Iterate through children and observe them for size changes.
  const handleChildrenChange = useCallback(() => {
    const listEle = listRef.current;
    const observer = resizeObserver();

    if (listEle) {
      for (const child of listEle.children) {
        if (child instanceof HTMLElement) {
          observer.observe(child);
        }
      }
    }
    handleRecalculate();
  }, [handleRecalculate, resizeObserver]);

  // Helper to get or create the mutation observer.
  const mutationObserver = useCallback(() => {
    const observer = (mutationObserverRef.current ??= new MutationObserver(
      handleChildrenChange,
    ));
    return observer;
  }, [handleChildrenChange]);

  // Set up observers.
  const handleObserve = useCallback(() => {
    if (wrapperRef.current) {
      resizeObserver().observe(wrapperRef.current);
    }
    if (listRef.current) {
      mutationObserver().observe(listRef.current, { childList: true });
      handleChildrenChange();
    }
  }, [handleChildrenChange, mutationObserver, resizeObserver]);

  // Watch the wrapper for size changes, and recalculate when it resizes.
  const wrapperRef = useRef<HTMLElement | null>(null);
  const wrapperRefCallback = useCallback(
    (node: HTMLElement | null) => {
      if (node) {
        wrapperRef.current = node;
        handleObserve();
      }
    },
    [handleObserve],
  );

  // If there are changes to the children, recalculate which are visible.
  const listRefCallback = useCallback(
    (node: HTMLElement | null) => {
      if (node) {
        listRef.current = node;
        handleObserve();
      }
    },
    [handleObserve],
  );

  useEffect(() => {
    handleObserve();

    return () => {
      if (resizeObserverRef.current) {
        resizeObserverRef.current.disconnect();
        resizeObserverRef.current = null;
      }
      if (mutationObserverRef.current) {
        mutationObserverRef.current.disconnect();
        mutationObserverRef.current = null;
      }
    };
  }, [handleObserve]);

  return {
    hiddenCount,
    hasOverflow: hiddenCount > 0,
    wrapperRef: wrapperRefCallback,
    hiddenIndex,
    maxWidth,
    listRef: listRefCallback,
    recalculate: handleRecalculate,
  };
}

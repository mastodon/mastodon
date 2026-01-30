import type { MutableRefObject, RefCallback } from 'react';
import { useState, useRef, useCallback, useEffect } from 'react';

/**
 * Hook to manage overflow of items in a container with a "more" button.
 *
 * To use, wire up the `wrapperRef` to the container element, and the `listRef` to the
 * child element that contains the items to be measured. If autoResize is true,
 * the list element will have its max-width set to prevent wrapping. The listRef element
 * requires both position:relative and overflow:hidden styles to work correctly.
 */
export function useOverflowButton({
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

  const { listRefCallback, wrapperRefCallback } = useOverflowObservers({
    onRecalculate: handleRecalculate,
    onListRef: listRef,
  });

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

export function useOverflowScroll({
  widthOffset = 200,
  absoluteDistance = false,
} = {}) {
  const [canScrollLeft, setCanScrollLeft] = useState(false);
  const [canScrollRight, setCanScrollRight] = useState(false);

  const bodyRef = useRef<HTMLElement | null>(null);

  // Recalculate scrollable state
  const handleRecalculate = useCallback(() => {
    if (!bodyRef.current) {
      return;
    }

    if (getComputedStyle(bodyRef.current).direction === 'rtl') {
      setCanScrollLeft(
        bodyRef.current.clientWidth - bodyRef.current.scrollLeft <
          bodyRef.current.scrollWidth,
      );
      setCanScrollRight(bodyRef.current.scrollLeft < 0);
    } else {
      setCanScrollLeft(bodyRef.current.scrollLeft > 0);
      setCanScrollRight(
        bodyRef.current.scrollLeft + bodyRef.current.clientWidth <
          bodyRef.current.scrollWidth,
      );
    }
  }, []);

  const { wrapperRefCallback } = useOverflowObservers({
    onRecalculate: handleRecalculate,
    onWrapperRef: bodyRef,
  });

  useEffect(() => {
    handleRecalculate();
  }, [handleRecalculate]);

  // Handle scroll event using requestAnimationFrame to avoid excessive recalculations.
  const handleScroll = useCallback(() => {
    requestAnimationFrame(handleRecalculate);
  }, [handleRecalculate]);

  // Jump a full screen minus the width offset so that we don't skip a lot.
  const handleLeftNav = useCallback(() => {
    if (!bodyRef.current) {
      return;
    }

    bodyRef.current.scrollLeft -= absoluteDistance
      ? widthOffset
      : Math.max(widthOffset, bodyRef.current.clientWidth - widthOffset);
  }, [absoluteDistance, widthOffset]);

  const handleRightNav = useCallback(() => {
    if (!bodyRef.current) {
      return;
    }

    bodyRef.current.scrollLeft += absoluteDistance
      ? widthOffset
      : Math.max(widthOffset, bodyRef.current.clientWidth - widthOffset);
  }, [absoluteDistance, widthOffset]);

  return {
    bodyRef: wrapperRefCallback,
    canScrollLeft,
    canScrollRight,
    handleLeftNav,
    handleRightNav,
    handleScroll,
  };
}

export function useOverflowObservers({
  onRecalculate,
  onListRef,
  onWrapperRef,
}: {
  onRecalculate: () => void;
  onListRef?: RefCallback<HTMLElement> | MutableRefObject<HTMLElement | null>;
  onWrapperRef?:
    | RefCallback<HTMLElement>
    | MutableRefObject<HTMLElement | null>;
}) {
  // This is the item container element.
  const listRef = useRef<HTMLElement | null>(null);

  // Set up observers to watch for size and content changes.
  const resizeObserverRef = useRef<ResizeObserver | null>(null);
  const mutationObserverRef = useRef<MutationObserver | null>(null);

  // Helper to get or create the resize observer.
  const resizeObserver = useCallback(() => {
    const observer = (resizeObserverRef.current ??= new ResizeObserver(
      onRecalculate,
    ));
    return observer;
  }, [onRecalculate]);

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
    onRecalculate();
  }, [onRecalculate, resizeObserver]);

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
        if (typeof onWrapperRef === 'function') {
          onWrapperRef(node);
        } else if (onWrapperRef && 'current' in onWrapperRef) {
          onWrapperRef.current = node;
        }
      }
    },
    [handleObserve, onWrapperRef],
  );

  // If there are changes to the children, recalculate which are visible.
  const listRefCallback = useCallback(
    (node: HTMLElement | null) => {
      if (node) {
        listRef.current = node;
        handleObserve();
        if (typeof onListRef === 'function') {
          onListRef(node);
        } else if (onListRef && 'current' in onListRef) {
          onListRef.current = node;
        }
      }
    },
    [handleObserve, onListRef],
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
    wrapperRefCallback,
    listRefCallback,
  };
}

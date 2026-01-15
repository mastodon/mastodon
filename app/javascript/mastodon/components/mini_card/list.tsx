import { useCallback, useEffect, useRef, useState } from 'react';
import type { FC, Key, MouseEventHandler } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { MiniCard } from '.';
import type { MiniCardProps } from '.';
import classes from './styles.module.css';

interface MiniCardListProps {
  cards?: (Pick<MiniCardProps, 'label' | 'value'> & { key?: Key })[];
  onOverflowClick?: MouseEventHandler;
}

export const MiniCardList: FC<MiniCardListProps> = ({
  cards = [],
  onOverflowClick,
}) => {
  const {
    wrapperRef,
    listRef,
    hiddenCount,
    hasOverflow,
    hiddenIndex,
    maxWidth,
  } = useOverflow();

  return (
    <div className={classes.wrapper} ref={wrapperRef}>
      <dl className={classes.list} ref={listRef} style={{ maxWidth }}>
        {cards.map((card, index) => (
          <MiniCard
            key={card.key ?? index}
            label={card.label}
            value={card.value}
            hidden={index >= hiddenIndex}
          />
        ))}
      </dl>
      <button
        type='button'
        className={classNames(classes.more, !hasOverflow && classes.hidden)}
        onClick={onOverflowClick}
      >
        <FormattedMessage
          id='minicard.more_items'
          defaultMessage='+ {count} more'
          values={{ count: hiddenCount }}
        />
      </button>
    </div>
  );
};

function useOverflow() {
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
      4;
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
  }, []);

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

  // Disconnect on unmount.
  useEffect(() => {
    const resizeObserverCleanup = resizeObserver();
    const mutationObserverCleanup = mutationObserver();

    return () => {
      resizeObserverCleanup.disconnect();
      mutationObserverCleanup.disconnect();
    };
  }, [mutationObserver, resizeObserver]);

  // Watch the wrapper for size changes, and recalculate when it resizes.
  const wrapperRef = useCallback(
    (node: HTMLElement | null) => {
      if (node) {
        resizeObserver().observe(node);
      }
    },
    [resizeObserver],
  );

  // If there are changes to the children, recalculate which are visible.
  const listRefCallback = useCallback(
    (node: HTMLElement | null) => {
      if (node) {
        mutationObserver().observe(node, { childList: true });
        listRef.current = node;
        handleChildrenChange();
      }
    },
    [handleChildrenChange, mutationObserver],
  );

  return {
    hiddenCount,
    hasOverflow: hiddenCount > 0,
    wrapperRef,
    hiddenIndex,
    maxWidth,
    listRef: listRefCallback,
    recalculate: handleRecalculate,
  };
}

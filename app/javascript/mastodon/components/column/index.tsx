import { useRef, useMemo } from 'react';

import classNames from 'classnames';

import { useDebouncedCallback } from 'use-debounce';

import { getColumnSkipLinkId } from '@/mastodon/features/ui/components/skip_links';
import { useScrollSensor } from '@/mastodon/hooks/useScrollSensor';
import { isRedesignEnabled } from '@/mastodon/utils/environment';
import { scrollTop } from 'mastodon/scroll';

import { ColumnContext, useColumnIndexContext } from './context';
import classes from './styles.module.scss';

interface ColumnProps {
  children?: React.ReactNode;
  label?: string;
  bindToDocument?: boolean;
  className?: string;
}

const TIMEOUT = 200;

export const Column: React.FC<ColumnProps> = ({
  children,
  label,
  bindToDocument,
  className,
}) => {
  const nodeRef = useRef<HTMLDivElement>(null);

  const { sensor: scrollSensor, isInViewport: isSensorInViewport } =
    useScrollSensor({
      placement: 'top',
    });

  const idleCallbackId = useRef<number>(null);
  const contextValue = useMemo(
    () => ({
      scrollSensor,
      isScrolledToTop: isSensorInViewport,
      scrollTop() {
        let scrollable = null;

        if (bindToDocument) {
          scrollable = document.scrollingElement;
        } else {
          scrollable = nodeRef.current;
        }

        if (!scrollable) {
          return;
        }

        idleCallbackId.current = scrollTop(scrollable, {
          timeout: TIMEOUT,
          callback() {
            idleCallbackId.current = null;
          },
        });
      },
    }),
    [bindToDocument, isSensorInViewport, scrollSensor],
  );

  const handleScroll = useDebouncedCallback(() => {
    if (typeof idleCallbackId.current === 'number') {
      cancelIdleCallback(idleCallbackId.current);
    }
  }, TIMEOUT);

  const columnIndex = useColumnIndexContext();

  return (
    <div
      role='region'
      ref={nodeRef}
      onScroll={handleScroll}
      className={classNames(
        isRedesignEnabled() ? classes.root : 'column',
        className,
      )}
      data-column-root // Used by hotkey handling code
      aria-label={label}
      aria-labelledby={
        label === undefined ? getColumnSkipLinkId(columnIndex) : undefined
      }
    >
      {
        // In multi-column mode, the scrollSensor is attached in <Scrollable>
        bindToDocument ? scrollSensor : null
      }
      <ColumnContext.Provider value={contextValue}>
        {children}
      </ColumnContext.Provider>
    </div>
  );
};

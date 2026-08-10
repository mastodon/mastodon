import { useRef, useMemo } from 'react';

import classNames from 'classnames';

import { useDebouncedCallback } from 'use-debounce';

import { scrollTop } from 'mastodon/scroll';

import { ColumnContext } from './context';

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

  const idleCallbackId = useRef<number>(null);
  const contextValue = useMemo(
    () => ({
      scrollTop() {
        let scrollable = null;

        if (bindToDocument) {
          scrollable = document.scrollingElement;
        } else {
          scrollable = nodeRef.current?.querySelector('.scrollable');
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
    [bindToDocument],
  );

  const handleScroll = useDebouncedCallback(() => {
    if (typeof idleCallbackId.current === 'number') {
      cancelIdleCallback(idleCallbackId.current);
    }
  }, TIMEOUT);

  return (
    <div
      role='region'
      aria-label={label}
      className={classNames('column', className)}
      ref={nodeRef}
      onScroll={handleScroll}
    >
      <ColumnContext.Provider value={contextValue}>
        {children}
      </ColumnContext.Provider>
    </div>
  );
};

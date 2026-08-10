import { useRef, createContext, useContext, useMemo } from 'react';

import classNames from 'classnames';

import { scrollTop } from 'mastodon/scroll';

interface ColumnProps {
  children?: React.ReactNode;
  label?: string;
  bindToDocument?: boolean;
  className?: string;
}

const ColumnContext = createContext({
  scrollTop: () => {
    // Implemented below
  },
});

export const useColumn = () => useContext(ColumnContext);

export const Column: React.FC<ColumnProps> = ({
  children,
  label,
  bindToDocument,
  className,
}) => {
  const nodeRef = useRef<HTMLDivElement>(null);

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

        scrollTop(scrollable);
      },
    }),
    [bindToDocument],
  );

  return (
    <div
      role='region'
      aria-label={label}
      className={classNames('column', className)}
      ref={nodeRef}
    >
      <ColumnContext.Provider value={contextValue}>
        {children}
      </ColumnContext.Provider>
    </div>
  );
};

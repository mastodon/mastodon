import { forwardRef, useRef, useImperativeHandle } from 'react';
import type { Ref } from 'react';

import { scrollTop } from 'mastodon/scroll';

export interface ColumnRef {
  scrollTop: () => void;
  node: HTMLDivElement | null;
}

interface ColumnProps {
  children?: React.ReactNode;
  label?: string;
  bindToDocument?: boolean;
}

export const Column = forwardRef<ColumnRef, ColumnProps>(
  ({ children, label, bindToDocument }, ref: Ref<ColumnRef>) => {
    const nodeRef = useRef<HTMLDivElement>(null);

    useImperativeHandle(ref, () => ({
      node: nodeRef.current,

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
    }));

    return (
      <div role='region' aria-label={label} className='column' ref={nodeRef}>
        {children}
      </div>
    );
  },
);

Column.displayName = 'Column';

// eslint-disable-next-line import/no-default-export
export default Column;

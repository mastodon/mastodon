import { useCallback, useState } from 'react';

import classNames from 'classnames';

import type { UniqueIdentifier } from '@dnd-kit/core';
import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';

import { ItemHandleContext } from './hooks';
import classes from './styles.module.scss';

type ValidItemElement = 'li' | 'div' | 'span' | 'p';

interface SortableListItemOwnProps<As extends ValidItemElement> {
  as?: As;
  id: UniqueIdentifier;
  draggingClassName?: string;
  overClassName?: string;
  noTransition?: boolean;
}

export type SortableListItemProps<As extends ValidItemElement> =
  SortableListItemOwnProps<As> &
    Omit<
      React.ComponentPropsWithoutRef<As>,
      keyof SortableListItemOwnProps<As>
    >;

export const SortableListItem = <As extends ValidItemElement = 'li'>({
  id,
  as: AsComp,
  children,
  className,
  draggingClassName,
  overClassName,
  style: componentStyle,
  noTransition,
  ...props
}: SortableListItemProps<As>) => {
  const ItemComponent = AsComp ?? 'li';

  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
    isOver,
  } = useSortable({
    id,
  });
  const [hasHandle, setHasHandle] = useState(false);
  const registerHandle = useCallback(() => {
    setHasHandle(true);
  }, []);

  const style = {
    ...componentStyle,
    transform: CSS.Translate.toString(transform),
    transition: noTransition ? undefined : transition,
    ['--transition']: transition,
  };

  return (
    <ItemComponent
      {...(props as React.HTMLAttributes<HTMLElement>)}
      {...(hasHandle ? null : listeners)}
      {...(hasHandle ? null : attributes)}
      style={style}
      ref={setNodeRef}
      className={classNames(
        className,
        classes.item,
        !hasHandle && classes.handle,
        isDragging && classes.active,
        isDragging && draggingClassName,
        isOver && overClassName,
      )}
      data-dragging={isDragging}
      data-over={isOver}
    >
      <ItemHandleContext.Provider value={{ registerHandle, id }}>
        {children}
      </ItemHandleContext.Provider>
    </ItemComponent>
  );
};

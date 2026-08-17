import classNames from 'classnames';

import { DotsSixVerticalIcon } from '@phosphor-icons/react';

import { useSortableHandle } from './hooks';
import classes from './styles.module.scss';

type ValidHandleElement = 'button' | 'span';

type SortableListHandleProps<As extends ValidHandleElement> = {
  as?: As;
} & React.ComponentPropsWithoutRef<As>;

export const SortableListHandle = <As extends ValidHandleElement = 'button'>({
  as: asComp,
  children,
  className,
  ...props
}: SortableListHandleProps<As>) => {
  const Component = asComp ?? 'button';
  const { attributes, listeners, isDragging } = useSortableHandle();

  return (
    <Component
      type={asComp === 'button' ? 'button' : undefined}
      {...props}
      {...attributes}
      {...listeners}
      className={classNames(
        className,
        classes.handle,
        classes.defaultHandle,
        isDragging && classes.active,
      )}
    >
      {children ?? <DotsSixVerticalIcon />}
    </Component>
  );
};

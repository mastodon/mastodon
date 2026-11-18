import type React from 'react';

import classNames from 'classnames';

import { Icon } from '../icon';
import type { IconProp } from '../icon';

import classes from './redesign.module.scss';

interface MiniCalloutProps {
  size: 'sm';
}

interface LargeCalloutProps {
  size?: 'lg';
  icon?: IconProp;
}

export type CalloutProps<As extends React.ElementType> = (
  | MiniCalloutProps
  | LargeCalloutProps
) & {
  as?: As;
  children: React.ReactNode;
  className?: string;
  actions?: React.ReactNode;
} & React.ComponentPropsWithoutRef<As>;

export const Callout = <As extends React.ElementType>({
  as: asComp,
  actions,
  size,
  children,
  className,
  ...props
}: CalloutProps<As>) => {
  const Comp = asComp ?? 'div';

  const wrappedChildren = <div className={classes.textWrapper}>{children}</div>;

  if (size === 'sm') {
    return (
      <Comp {...props} className={classNames(className, classes.rootSmall)}>
        {wrappedChildren}
        {actions}
      </Comp>
    );
  }

  const { icon, ...restProps } = props;

  return (
    <Comp {...restProps} className={classNames(className, classes.rootLarge)}>
      <div className={classes.content}>
        {icon && <Icon icon={icon} className={classes.icon} />}
        {wrappedChildren}
      </div>
      {actions && <div className={classes.actions}>{actions}</div>}
    </Comp>
  );
};

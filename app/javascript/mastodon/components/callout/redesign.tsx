import type React from 'react';

import classNames from 'classnames';

import { Button } from '../button/redesign';
import { Icon } from '../icon';
import type { IconProp } from '../icon';

import classes from './redesign.module.scss';

type RenameKeysStartingWith<
  TObject extends Record<string, unknown>,
  TPrefix extends string,
  TReplacement extends string,
> = {
  [TKey in keyof TObject as TKey extends `${TPrefix}${infer TSuffix}`
    ? `${TReplacement}${TSuffix}`
    : TKey]: TObject[TKey];
};

type ActionProps =
  | { actionClick: () => void; actionText: React.ReactNode }
  | { actionClick?: never; actionText?: never };

type MiniCalloutProps = {
  size: 'sm';
} & ActionProps;

type LargeCalloutProps = {
  size?: 'lg';
  icon?: IconProp;
} & (
  | (ActionProps & {
      secondaryActionClick?: never;
      secondaryActionText?: never;
    })
  | (Required<ActionProps> &
      RenameKeysStartingWith<ActionProps, 'action', 'secondaryAction'>)
);

export type CalloutProps<As extends React.ElementType> = (
  | MiniCalloutProps
  | LargeCalloutProps
) & {
  as?: As;
  children: React.ReactNode;
  className?: string;
} & React.ComponentPropsWithoutRef<As>;

export const Callout = <As extends React.ElementType>({
  as: asComp,
  size,
  children,
  className,
  actionText,
  actionClick,
  ...props
}: CalloutProps<As>) => {
  const Comp = asComp ?? 'div';

  const wrappedChildren = <div className={classes.textWrapper}>{children}</div>;

  const actionButton = actionText ? (
    <Button onClick={actionClick} size={size === 'sm' ? 'xs' : 'sm'}>
      {actionText}
    </Button>
  ) : null;

  if (size === 'sm') {
    return (
      <Comp {...props} className={classNames(className, classes.rootSmall)}>
        {wrappedChildren}
        {actionButton}
      </Comp>
    );
  }

  const { icon, secondaryActionClick, secondaryActionText, ...restProps } =
    props;

  const secondaryButton = secondaryActionText ? (
    <Button onClick={secondaryActionClick} size='sm' variant='ghost'>
      {secondaryActionText}
    </Button>
  ) : null;

  return (
    <Comp {...restProps} className={classNames(className, classes.rootLarge)}>
      {icon && <Icon icon={icon} className={classes.icon} />}
      {wrappedChildren}
      {actionButton}
      {secondaryButton}
    </Comp>
  );
};

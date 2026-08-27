import classNames from 'classnames';

import type { PolymorphicProps } from '@/types/polymorphic';

import { Popover } from '../popover';
import type { PopoverProps } from '../popover';

import classes from './styles.module.scss';

export type MenuCardProps<As extends React.ElementType> = PolymorphicProps<
  {
    children: React.ReactNode;
    className?: string;
    elevation?: 1 | 2;
    maxWidth?: number | string;
    style?: React.CSSProperties;
  },
  As
>;

export const MenuCard = <As extends React.ElementType = 'div'>({
  as: asComp,
  children,
  className,
  elevation = 1,
  maxWidth,
  style,
  ...props
}: MenuCardProps<As>) => {
  const Component = asComp ?? 'div';
  return (
    <Component
      {...props}
      className={classNames(className, classes.card)}
      data-elevation={elevation}
      style={
        {
          '--_max-card-width':
            typeof maxWidth === 'number' ? `${maxWidth}px` : maxWidth,
          ...style,
        } as React.CSSProperties
      }
    >
      {children}
    </Component>
  );
};

export type PopoverMenuCardProps<As extends React.ElementType> =
  MenuCardProps<As> & Omit<PopoverProps, 'children'>;

export const PopoverMenuCard = <As extends React.ElementType>({
  isOpen,
  onClose,
  reference,
  popoverElement,
  container,
  placement,
  offset = 4,
  flip,
  strategy,
  matchReferenceWidth,
  closeOnClickOutside,
  children,
  className,
  ...props
}: PopoverMenuCardProps<As>) => {
  return (
    <Popover
      isOpen={isOpen}
      onClose={onClose}
      reference={reference}
      popoverElement={popoverElement}
      container={container}
      placement={placement}
      offset={offset}
      flip={flip}
      strategy={strategy}
      matchReferenceWidth={matchReferenceWidth}
      closeOnClickOutside={closeOnClickOutside}
    >
      {({ props: popoverChildProps }) => (
        <MenuCard
          {...popoverChildProps}
          {...(props as React.ComponentPropsWithoutRef<As>)}
          className={classNames(
            className,
            props.maxWidth && classes.popoverCard,
          )}
        >
          {children}
        </MenuCard>
      )}
    </Popover>
  );
};

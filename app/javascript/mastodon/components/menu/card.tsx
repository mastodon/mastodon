import { useLayoutEffect, useRef } from 'react';

import classNames from 'classnames';

import { useBreakpoint } from '@/mastodon/features/ui/hooks/useBreakpoint';
import { useMergedRefs } from '@/mastodon/hooks/useMergedRefs';
import type { PolymorphicProps } from '@/types/polymorphic';

import { BottomSheet } from '../bottom_sheet';
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
    popover?: React.HTMLAttributes<As>['popover'];
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
  // By default, `MenuCard` opens itself on the top layer using the
  // native popover API. Set this prop to `undefined` to disable this.
  popover = 'manual',
  ...props
}: MenuCardProps<As>) => {
  const Component = asComp ?? 'div';
  const cardRef = useRef<HTMLDivElement>(null);

  useLayoutEffect(() => {
    const card = cardRef.current;
    if (popover !== 'manual' || !card || !isPopoverAPISupported()) return;

    card.showPopover();

    return () => {
      card.hidePopover();
    };
  }, [popover]);

  return (
    <Component
      {...props}
      ref={useMergedRefs(props.ref, cardRef)}
      popover={popover}
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

function isPopoverAPISupported() {
  return 'popover' in HTMLElement.prototype;
}

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
  const isMobile = useBreakpoint('openable');

  if (isMobile && isOpen) {
    return (
      <BottomSheet {...props} onClose={onClose}>
        {children}
      </BottomSheet>
    );
  }

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

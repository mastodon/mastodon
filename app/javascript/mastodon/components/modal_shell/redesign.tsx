import type React from 'react';

import classNames from 'classnames';

import type { PolymorphicProps } from '@/types/polymorphic';

import type { NamedFocusTarget } from '../navigation_focus_target';
import { NavigationFocusTarget } from '../navigation_focus_target';

import classes from './redesign.module.scss';

export interface ModalShellProps {
  children: React.ReactNode;
  className?: string;
  elevation?: 1 | 2;
  maxWidth?: number;
  style?: React.CSSProperties;
}

export const ModalShell = <As extends React.ElementType>({
  as: asComp,
  elevation,
  className,
  children,
  maxWidth,
  style,
  ...props
}: PolymorphicProps<ModalShellProps, As>) => {
  const Comp = asComp ?? 'div';
  return (
    <Comp
      {...props}
      className={classNames(
        className,
        classes.modal,
        elevation === 2 && classes.modalElevated,
      )}
      style={{
        maxWidth: maxWidth ? `${maxWidth}px` : undefined,
        ...style,
      }}
    >
      {children}
    </Comp>
  );
};

type HeadingLevels = 1 | 2 | 3 | 4 | 5 | 6;

type ModalTitleProps = { children: React.ReactNode; level?: HeadingLevels } & (
  | { noFocus: true }
  | { noFocus?: false; focusTargetName?: NamedFocusTarget }
);

export const ModalTitle: React.FC<
  ModalTitleProps & React.ComponentPropsWithRef<`h${HeadingLevels}`>
> = ({ level = 1, children, className, noFocus, ...props }) => {
  const Header = `h${level}` as const;
  if (!noFocus) {
    return (
      <NavigationFocusTarget
        as={Header}
        {...props}
        className={classNames(className, classes.title)}
      >
        {children}
      </NavigationFocusTarget>
    );
  }
  return (
    <Header {...props} className={classNames(className, classes.title)}>
      {children}
    </Header>
  );
};

export const ModalActions = <As extends React.ElementType>({
  align,
  as: asComp,
  children,
  className,
  ...props
}: PolymorphicProps<
  {
    align?: 'left' | 'right' | 'stretch';
    children?: React.ReactNode;
    className?: string;
  },
  As
>) => {
  const Comp = asComp ?? 'div';

  return (
    <Comp
      {...props}
      className={classNames(
        className,
        classes.actions,
        align === 'left' && classes.actionsLeft,
        align === 'right' && classes.actionsRight,
      )}
    >
      {children}
    </Comp>
  );
};

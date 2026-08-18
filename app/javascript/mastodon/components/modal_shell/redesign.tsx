import type React from 'react';

import classNames from 'classnames';

import type { PolymorphicProps } from '@/types/polymorphic';

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

export const ModalTitle: React.FC<
  {
    children: React.ReactNode;
    level?: 1 | 2 | 3 | 4 | 5 | 6;
  } & React.ComponentPropsWithRef<`h${HeadingLevels}`>
> = ({ level = 2, children, className, ...props }) => {
  const Header = `h${level}` as const;
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

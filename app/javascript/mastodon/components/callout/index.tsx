import type { FC, ReactNode } from 'react';

import classNames from 'classnames';

import classes from './styles.module.css';

interface Action {
  label: string;
  onClick: () => void;
}

interface CalloutProps {
  variant?:
    | 'default'
    | 'subtle'
    | 'feature'
    | 'inverted'
    | 'success'
    | 'warning'
    | 'error';
  title?: ReactNode;
  children: ReactNode;
  className?: string;
  /** Set to false or null to hide the icon. */
  icon?: ReactNode;
  primaryAction?: Action;
  secondaryAction?: Action;
  noClose?: boolean;
}

export const Callout: FC<CalloutProps> = ({ className }) => {
  const wrapperClassName = classNames(className, classes.wrapper);
  return <aside className={wrapperClassName}>Callout component</aside>;
};

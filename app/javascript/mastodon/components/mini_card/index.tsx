import type { FC, ReactNode } from 'react';

import classNames from 'classnames';

import classes from './styles.module.css';

export interface MiniCardProps {
  label: ReactNode;
  value: ReactNode;
  className?: string;
}

export const MiniCard: FC<MiniCardProps> = ({ label, value, className }) => {
  if (!label) {
    return null;
  }

  return (
    <div className={classNames(classes.card, className)}>
      <dt className={classes.label}>{label}</dt>
      <dd className={classes.value}>{value}</dd>
    </div>
  );
};

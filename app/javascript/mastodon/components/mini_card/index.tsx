import type { FC, ReactNode } from 'react';

import classNames from 'classnames';

import classes from './styles.module.css';

export interface MiniCardProps {
  label: ReactNode;
  value: ReactNode;
  className?: string;
  hidden?: boolean;
}

export const MiniCard: FC<MiniCardProps> = ({
  label,
  value,
  className,
  hidden,
}) => {
  if (!label) {
    return null;
  }

  return (
    <div
      className={classNames(classes.card, className)}
      inert={hidden ? '' : undefined}
    >
      <dt className={classes.label}>{label}</dt>
      <dd className={classes.value}>{value}</dd>
    </div>
  );
};

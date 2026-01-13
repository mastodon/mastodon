import type { FC, ReactNode } from 'react';

import classNames from 'classnames';

import classes from './styles.module.css';

export interface MiniCardProps {
  label: ReactNode;
  value: ReactNode;
  className?: string;
}

export const MiniCard: FC<MiniCardProps> = ({ label, value, className }) => {
  if (!value || !label) {
    return null;
  }

  if (typeof value === 'string') {
    const url = toUrl(value);
    if (url) {
      value = <a href={url.toString()}>{url.hostname}</a>;
    }
  }

  return (
    <div className={classNames(classes.card, className)}>
      <dt className={classes.label}>{label}</dt>
      <dd className={classes.value}>{value}</dd>
    </div>
  );
};

function toUrl(value: string) {
  try {
    const url = new URL(value);
    if (url.protocol !== 'https:') {
      return null;
    }
    return url;
  } catch {}
  return null;
}

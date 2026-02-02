import { forwardRef } from 'react';
import type { ComponentPropsWithoutRef, ReactNode } from 'react';

import classNames from 'classnames';

import type { OmitUnion } from '@/mastodon/utils/types';

import { Icon } from '../icon';
import type { IconProp } from '../icon';

import classes from './styles.module.css';

export type MiniCardProps = OmitUnion<
  ComponentPropsWithoutRef<'div'>,
  {
    label: ReactNode;
    value: ReactNode;
    icon?: IconProp;
    iconId?: string;
    iconClassName?: string;
  }
>;

export const MiniCard = forwardRef<HTMLDivElement, MiniCardProps>(
  (
    { label, value, className, hidden, icon, iconId, iconClassName, ...props },
    ref,
  ) => {
    if (!label) {
      return null;
    }

    return (
      <div
        {...props}
        className={classNames(
          classes.card,
          icon && classes.cardWithIcon,
          className,
        )}
        ref={ref}
      >
        {icon && (
          <Icon
            id={iconId ?? 'minicard'}
            icon={icon}
            className={classNames(classes.icon, iconClassName)}
            noFill
          />
        )}
        <dt className={classes.label}>{label}</dt>
        <dd className={classes.value}>{value}</dd>
      </div>
    );
  },
);
MiniCard.displayName = 'MiniCard';

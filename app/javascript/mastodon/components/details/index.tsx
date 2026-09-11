import { forwardRef } from 'react';
import type { ComponentPropsWithoutRef, ReactNode } from 'react';

import classNames from 'classnames';

import ExpandArrowIcon from '@/material-icons/400-24px/expand_more.svg?react';

import { Icon } from '../icon';

import classes from './styles.module.scss';

export const Details = forwardRef<
  HTMLDetailsElement,
  {
    summary: ReactNode;
    children: ReactNode;
    className?: string;
  } & ComponentPropsWithoutRef<'details'>
>(({ summary, children, className, ...rest }, ref) => {
  return (
    <details
      ref={ref}
      className={classNames(classes.details, className)}
      {...rest}
    >
      <summary>
        {summary}
        <Icon icon={ExpandArrowIcon} id='arrow' />
      </summary>

      {children}
    </details>
  );
});
Details.displayName = 'Details';

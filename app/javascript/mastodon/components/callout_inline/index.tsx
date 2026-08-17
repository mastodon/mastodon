import type { FC } from 'react';

import classNames from 'classnames';

import CheckIcon from '@/material-icons/400-24px/check.svg?react';
import ErrorIcon from '@/material-icons/400-24px/error.svg?react';
import InfoIcon from '@/material-icons/400-24px/info.svg?react';
import WarningIcon from '@/material-icons/400-24px/warning.svg?react';

import type { FieldStatus } from '../form_fields/form_field_wrapper';
import { Icon } from '../icon';

import classes from './styles.module.css';

const iconMap: Record<FieldStatus['variant'], React.FunctionComponent> = {
  error: ErrorIcon,
  warning: WarningIcon,
  info: InfoIcon,
  success: CheckIcon,
};

export const CalloutInline: FC<
  Partial<FieldStatus> & React.ComponentPropsWithoutRef<'div'>
> = ({ variant = 'error', message, className, children, ...props }) => {
  return (
    <div
      {...props}
      className={classNames(className, classes.wrapper)}
      data-variant={variant}
    >
      <Icon id={variant} icon={iconMap[variant]} className={classes.icon} />
      {message ?? children}
    </div>
  );
};

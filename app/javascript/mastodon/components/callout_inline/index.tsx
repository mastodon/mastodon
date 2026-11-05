import type { FC } from 'react';

import classNames from 'classnames';

import type { Icon } from '@phosphor-icons/react';
import {
  CheckCircleIcon,
  InfoIcon,
  WarningCircleIcon,
} from '@phosphor-icons/react';

import type { FieldStatus } from '../form_fields/form_field_wrapper';

import classes from './styles.module.scss';

const iconMap: Record<FieldStatus['variant'], Icon> = {
  error: WarningCircleIcon,
  info: InfoIcon,
  success: CheckCircleIcon,
};

export const CalloutInline: FC<
  Partial<FieldStatus> & React.ComponentPropsWithoutRef<'div'>
> = ({ variant = 'error', message, className, children, ...props }) => {
  const IconComp = iconMap[variant];
  return (
    <div
      {...props}
      className={classNames(className, classes.wrapper)}
      data-variant={variant}
    >
      <IconComp weight='fill' className={classes.icon} />
      {message ?? children}
    </div>
  );
};

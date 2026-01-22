import type { FC, ReactNode } from 'react';

import classNames from 'classnames';

import CheckIcon from '@/material-icons/400-24px/check.svg?react';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import InfoIcon from '@/material-icons/400-24px/info.svg?react';
import WarningIcon from '@/material-icons/400-24px/warning.svg?react';

import type { IconProp } from '../icon';
import { Icon } from '../icon';
import { IconButton } from '../icon_button';

import classes from './styles.module.css';

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
  /** Set to false to hide the icon. */
  icon?: IconProp | boolean;
  primaryAction?: () => void;
  primaryLabel?: string;
  secondaryAction?: () => void;
  secondaryLabel?: string;
  noClose?: boolean;
}

const variantClasses = {
  default: classes.variantDefault as string,
  subtle: classes.variantSubtle as string,
  feature: classes.variantFeature as string,
  inverted: classes.variantInverted as string,
  success: classes.variantSuccess as string,
  warning: classes.variantWarning as string,
  error: classes.variantError as string,
} as const;

export const Callout: FC<CalloutProps> = ({
  className,
  variant = 'default',
  title,
  children,
  icon,
  primaryAction,
  primaryLabel,
  secondaryAction,
  secondaryLabel,
  noClose,
}) => {
  const wrapperClassName = classNames(className, classes.wrapper, {
    [variantClasses.default]: variant === 'default',
    [variantClasses.subtle]: variant === 'subtle',
    [variantClasses.feature]: variant === 'feature',
    [variantClasses.inverted]: variant === 'inverted',
    [variantClasses.success]: variant === 'success',
    [variantClasses.warning]: variant === 'warning',
    [variantClasses.error]: variant === 'error',
  });

  return (
    <aside className={wrapperClassName} data-variant={variant}>
      <CalloutIcon variant={variant} icon={icon} />
      <div className={classes.content}>
        <div>
          {title && <h3>{title}</h3>}
          {children}
        </div>

        {(primaryAction ?? secondaryAction) && (
          <div className={classes.action}>
            {secondaryAction && (
              <button type='button' onClick={secondaryAction}>
                {secondaryLabel ?? 'Click'}
              </button>
            )}

            {primaryAction && (
              <button type='button' onClick={primaryAction}>
                {primaryLabel ?? 'Click'}
              </button>
            )}
          </div>
        )}
      </div>

      {!noClose && (
        <IconButton
          icon='close'
          title=''
          iconComponent={CloseIcon}
          className={classes.close}
        />
      )}
    </aside>
  );
};

const CalloutIcon: FC<Pick<CalloutProps, 'variant' | 'icon'>> = ({
  variant = 'default',
  icon,
}) => {
  if (icon === false) {
    return null;
  }

  if (!icon || icon === true) {
    switch (variant) {
      case 'inverted':
      case 'success':
        icon = CheckIcon;
        break;
      case 'warning':
        icon = WarningIcon;
        break;
      default:
        icon = InfoIcon;
    }
  }

  return <Icon id={variant} icon={icon} className={classes.icon} />;
};

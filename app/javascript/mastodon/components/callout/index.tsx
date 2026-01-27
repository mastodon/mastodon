import type { FC, ReactNode } from 'react';

import { useIntl } from 'react-intl';

import classNames from 'classnames';

import CheckIcon from '@/material-icons/400-24px/check.svg?react';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import ErrorIcon from '@/material-icons/400-24px/error.svg?react';
import InfoIcon from '@/material-icons/400-24px/info.svg?react';
import WarningIcon from '@/material-icons/400-24px/warning.svg?react';

import type { IconProp } from '../icon';
import { Icon } from '../icon';
import { IconButton } from '../icon_button';

import classes from './styles.module.css';

export interface CalloutProps {
  variant?:
    | 'default'
    // | 'subtle'
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
  onPrimary?: () => void;
  primaryLabel?: string;
  onSecondary?: () => void;
  secondaryLabel?: string;
  onClose?: () => void;
  id?: string;
  extraContent?: ReactNode;
}

const variantClasses = {
  default: classes.variantDefault as string,
  // subtle: classes.variantSubtle as string,
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
  onPrimary: primaryAction,
  primaryLabel,
  onSecondary: secondaryAction,
  secondaryLabel,
  onClose,
  extraContent,
  id,
}) => {
  const intl = useIntl();

  return (
    <aside
      className={classNames(
        className,
        classes.wrapper,
        variantClasses[variant],
      )}
      data-variant={variant}
      id={id}
    >
      <CalloutIcon variant={variant} icon={icon} />
      <div className={classes.content}>
        <div className={classes.body}>
          {title && <h3>{title}</h3>}
          {children}
        </div>

        {(primaryAction ?? secondaryAction) && (
          <div className={classes.actionWrapper}>
            {secondaryAction && (
              <button
                type='button'
                onClick={secondaryAction}
                className={classes.action}
              >
                {secondaryLabel ?? 'Click'}
              </button>
            )}

            {primaryAction && (
              <button
                type='button'
                onClick={primaryAction}
                className={classes.action}
              >
                {primaryLabel ?? 'Click'}
              </button>
            )}
          </div>
        )}
      </div>

      {extraContent}

      {onClose && (
        <IconButton
          icon='close'
          title={intl.formatMessage({
            id: 'callout.dismiss',
            defaultMessage: 'Dismiss',
          })}
          iconComponent={CloseIcon}
          className={classes.close}
          onClick={onClose}
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
      case 'error':
        icon = ErrorIcon;
        break;
      default:
        icon = InfoIcon;
    }
  }

  return <Icon id={variant} icon={icon} className={classes.icon} />;
};

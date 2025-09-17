import { useIntl } from 'react-intl';

import classNames from 'classnames';

import CloseIcon from '@/material-icons/400-24px/close.svg?react';

import { IconButton } from '../icon_button';

/**
 * Snackbar/Toast-style notification component.
 */
export const Alert: React.FC<{
  isActive?: boolean;
  animateFrom?: 'side' | 'below';
  title?: string;
  message: string;
  action?: string;
  onActionClick?: () => void;
  onDismiss?: () => void;
}> = ({
  isActive,
  animateFrom = 'side',
  title,
  message,
  action,
  onActionClick,
  onDismiss,
}) => {
  const intl = useIntl();

  const hasAction = Boolean(action && onActionClick);

  return (
    <div
      className={classNames('notification-bar', {
        'notification-bar--active': isActive,
        'from-side': animateFrom === 'side',
        'from-below': animateFrom === 'below',
      })}
    >
      {!!title && <span className='notification-bar-title'>{title}</span>}

      <span className='notification-bar-message'>{message}</span>

      {hasAction && (
        <button className='notification-bar-action' onClick={onActionClick}>
          {action}
        </button>
      )}

      {!!onDismiss && (
        <IconButton
          title={intl.formatMessage({
            id: 'dismissable_banner.dismiss',
            defaultMessage: 'Dismiss',
          })}
          icon='times'
          iconComponent={CloseIcon}
          className='notification-bar-dismiss-button'
          onClick={onDismiss}
        />
      )}
    </div>
  );
};

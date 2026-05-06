import { useIntl } from 'react-intl';

import classNames from 'classnames';

import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';

import { IconButton } from '../icon_button';

/**
 * Snackbar/Toast-style notification component.
 */
export const Alert: React.FC<{
  title?: string;
  message: string;
  action?: string;
  onActionClick?: () => void;
  onDismiss?: () => void;
  isActive?: boolean;
  isLoading?: boolean;
  animateFrom?: 'side' | 'below';
}> = ({
  title,
  message,
  action,
  onActionClick,
  onDismiss,
  isActive,
  isLoading,
  animateFrom = 'side',
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
      <span className='notification-bar__content'>
        {Boolean(title) && (
          <span className='notification-bar__title'>{title}</span>
        )}
        {message}
      </span>

      {hasAction && (
        <button
          className='notification-bar__action'
          onClick={onActionClick}
          type='button'
        >
          {action}
        </button>
      )}

      {isLoading && (
        <span className='notification-bar__loading-indicator'>
          <LoadingIndicator />
        </span>
      )}

      {onDismiss && !isLoading && (
        <IconButton
          title={intl.formatMessage({
            id: 'dismissable_banner.dismiss',
            defaultMessage: 'Dismiss',
          })}
          icon='times'
          iconComponent={CloseIcon}
          className='notification-bar__dismiss-button'
          onClick={onDismiss}
        />
      )}
    </div>
  );
};

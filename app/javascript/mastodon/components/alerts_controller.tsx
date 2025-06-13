import { useState, useEffect } from 'react';

import { useIntl } from 'react-intl';
import type { IntlShape } from 'react-intl';

import classNames from 'classnames';

import { dismissAlert } from 'mastodon/actions/alerts';
import type {
  Alert,
  TranslatableString,
  TranslatableValues,
} from 'mastodon/models/alert';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

const formatIfNeeded = (
  intl: IntlShape,
  message: TranslatableString,
  values?: TranslatableValues,
) => {
  if (typeof message === 'object') {
    return intl.formatMessage(message, values);
  }

  return message;
};

const Alert: React.FC<{
  alert: Alert;
  dismissAfter: number;
}> = ({
  alert: { key, title, message, values, action, onClick },
  dismissAfter,
}) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();
  const [active, setActive] = useState(false);

  useEffect(() => {
    const setActiveTimeout = setTimeout(() => {
      setActive(true);
    }, 1);

    return () => {
      clearTimeout(setActiveTimeout);
    };
  }, []);

  useEffect(() => {
    const dismissTimeout = setTimeout(() => {
      setActive(false);

      // Allow CSS transition to finish before removing from the DOM
      setTimeout(() => {
        dispatch(dismissAlert({ key }));
      }, 500);
    }, dismissAfter);

    return () => {
      clearTimeout(dismissTimeout);
    };
  }, [dispatch, setActive, key, dismissAfter]);

  return (
    <div
      className={classNames('notification-bar', {
        'notification-bar-active': active,
      })}
    >
      <div className='notification-bar-wrapper'>
        {title && (
          <span className='notification-bar-title'>
            {formatIfNeeded(intl, title, values)}
          </span>
        )}

        <span className='notification-bar-message'>
          {formatIfNeeded(intl, message, values)}
        </span>

        {action && (
          <button className='notification-bar-action' onClick={onClick}>
            {formatIfNeeded(intl, action, values)}
          </button>
        )}
      </div>
    </div>
  );
};

export const AlertsController: React.FC = () => {
  const alerts = useAppSelector((state) => state.alerts);

  if (alerts.length === 0) {
    return null;
  }

  return (
    <div className='notification-list'>
      {alerts.map((alert, idx) => (
        <Alert key={alert.key} alert={alert} dismissAfter={5000 + idx * 1000} />
      ))}
    </div>
  );
};

import { useState, useEffect } from 'react';

import { defineMessage, useIntl } from 'react-intl';
import type { IntlShape } from 'react-intl';

import { dismissAlert } from 'mastodon/actions/alerts';
import type {
  Alert as AlertType,
  TranslatableString,
  TranslatableValues,
} from 'mastodon/models/alert';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { A11yLiveRegion } from './a11y_live_region';
import { Alert } from './alert';

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

const TimedAlert: React.FC<{
  alert: AlertType;
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
    <Alert
      isActive={active}
      title={title ? formatIfNeeded(intl, title, values) : undefined}
      message={formatIfNeeded(intl, message, values)}
      action={action ? formatIfNeeded(intl, action, values) : undefined}
      onActionClick={onClick}
    />
  );
};

export const AlertsController: React.FC = () => {
  const alerts = useAppSelector((state) => state.alerts);
  const needsReload = useAppSelector(
    (state) => !!state.meta.get('needsReload'),
  );

  return (
    <A11yLiveRegion className='notification-list'>
      {alerts.map((alert, idx) => (
        <TimedAlert
          key={alert.key}
          alert={alert}
          dismissAfter={5000 + idx * 1000}
        />
      ))}
      {needsReload && <ReloadAlert />}
    </A11yLiveRegion>
  );
};

const reloadMessage = defineMessage({
  id: 'alert.need_reload.message',
  defaultMessage:
    'Mastodon has been updated. Some things may not work correctly until you reload the page.',
});

const ReloadAlert: React.FC = () => {
  const intl = useIntl();
  return <Alert isActive message={intl.formatMessage(reloadMessage)} />;
};

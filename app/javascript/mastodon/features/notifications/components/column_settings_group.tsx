import { useCallback } from 'react';
import type { FC, ReactNode } from 'react';

import { defineMessages, FormattedMessage } from 'react-intl';

import { showAlert } from '@/mastodon/actions/alerts';
import { requestBrowserPermission } from '@/mastodon/actions/notifications';
import { changeAlerts } from '@/mastodon/actions/push_notifications';
import { changeSetting } from '@/mastodon/actions/settings';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';

import SettingToggle from './setting_toggle';

const selectNotificationSettings = createAppSelector(
  [
    (state) =>
      (state.settings as Immutable.Map<string, unknown>).get(
        'notifications',
      ) as Immutable.Map<string, Immutable.Map<string, unknown> | boolean>,
    (state) => state.notifications.get('browserPermission') as string,
    (state) => state.push_notifications,
  ],
  (settings, browserPermission, pushSettings) => ({
    settings,
    browserPermission: browserPermission !== 'denied',
    pushSettings,
    showPushSettings:
      pushSettings.get('supported') && pushSettings.get('enabled'),
  }),
);

const messages = defineMessages({
  permissionDenied: {
    id: 'notifications.permission_denied_alert',
    defaultMessage:
      "Desktop notifications can't be enabled, as browser permission has been denied before",
  },
});

type SettingsType = 'alerts' | 'shows' | 'sounds';

export const ColumnSettingsGroup: FC<{ label: ReactNode; type: string }> = ({
  label,
  type,
}) => {
  const { settings, browserPermission, pushSettings, showPushSettings } =
    useAppSelector(selectNotificationSettings);

  const dispatch = useAppDispatch();
  const handleChange = useCallback(
    (path: [SettingsType, string], checked: boolean) => {
      if (
        path[0] === 'alerts' &&
        checked &&
        typeof window.Notification !== 'undefined' &&
        Notification.permission !== 'granted'
      ) {
        dispatch(
          requestBrowserPermission((permission) => {
            if (permission === 'granted') {
              dispatch(changeSetting(['notifications', ...path], checked));
            } else {
              dispatch(showAlert({ message: messages.permissionDenied }));
            }
          }),
        );
      } else {
        dispatch(changeSetting(['notifications', ...path], checked));
      }
    },
    [dispatch],
  );
  const handlePushChange = useCallback(
    (path: string[], checked: boolean) => {
      if (
        checked &&
        typeof window.Notification !== 'undefined' &&
        Notification.permission !== 'granted'
      ) {
        dispatch(
          requestBrowserPermission((permission: NotificationPermission) => {
            if (permission === 'granted') {
              dispatch(changeAlerts(path, checked));
            } else {
              dispatch(showAlert({ message: messages.permissionDenied }));
            }
          }),
        );
      } else {
        dispatch(changeAlerts(path, checked));
      }
    },
    [dispatch],
  );

  return (
    <section role='group' aria-labelledby={`notifications-${type}`}>
      <h3 id={`notifications-${type}`}>{label}</h3>

      <div className='column-settings__row'>
        <SettingToggle
          disabled={!browserPermission}
          prefix='notifications_desktop'
          settings={settings}
          settingPath={['alerts', type]}
          onChange={handleChange}
          label={
            <FormattedMessage
              id='notifications.column_settings.alert'
              defaultMessage='Desktop notifications'
            />
          }
        />

        {showPushSettings && (
          <SettingToggle
            prefix='notifications_push'
            settings={pushSettings}
            settingPath={['alerts', type]}
            onChange={handlePushChange}
            label={
              <FormattedMessage
                id='notifications.column_settings.push'
                defaultMessage='Push notifications'
              />
            }
          />
        )}

        <SettingToggle
          prefix='notifications'
          settings={settings}
          settingPath={['shows', type]}
          onChange={handleChange}
          label={
            <FormattedMessage
              id='notifications.column_settings.show'
              defaultMessage='Show in column'
            />
          }
        />

        <SettingToggle
          prefix='notifications'
          settings={settings}
          settingPath={['sounds', type]}
          onChange={handleChange}
          label={
            <FormattedMessage
              id='notifications.column_settings.sound'
              defaultMessage='Play sound'
            />
          }
        />
      </div>
    </section>
  );
};

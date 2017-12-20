import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';
import ClearColumnButton from './clear_column_button';
import SettingToggle from './setting_toggle';
import { supportsDesktopNotifications, supportsPushNotifications } from '../../../agent';

export default class ColumnSettings extends React.PureComponent {

  static propTypes = {
    settings: ImmutablePropTypes.map.isRequired,
    pushSettings: ImmutablePropTypes.map.isRequired,
    onChange: PropTypes.func.isRequired,
    onSave: PropTypes.func.isRequired,
    onClear: PropTypes.func.isRequired,
  };

  onPushChange = (key, checked) => {
    this.props.onChange(['push', ...key], checked);
  }

  render () {
    const { settings, pushSettings, onChange, onClear } = this.props;

    const alertStr = <FormattedMessage id='notifications.column_settings.alert' defaultMessage='Desktop notifications' />;
    const showStr  = <FormattedMessage id='notifications.column_settings.show' defaultMessage='Show in column' />;
    const soundStr = <FormattedMessage id='notifications.column_settings.sound' defaultMessage='Play sound' />;

    const showDesktopSettings = supportsDesktopNotifications();
    const showPushSettings = supportsPushNotifications() && pushSettings.get('isSubscribed');
    const pushStr = showPushSettings && <FormattedMessage id='notifications.column_settings.push' defaultMessage='Push notifications' />;
    const pushMeta = showPushSettings && <FormattedMessage id='notifications.column_settings.push_meta' defaultMessage='This device' />;

    return (
      <div>
        <div className='column-settings__row'>
          <ClearColumnButton onClick={onClear} />
        </div>

        {[
          {
            key: 'follow',
            label: <FormattedMessage id='notifications.column_settings.follow' defaultMessage='New followers:' />,
          }, {
            key: 'favourite',
            label: <FormattedMessage id='notifications.column_settings.favourite' defaultMessage='Favourites:' />,
          }, {
            key: 'mention',
            label: <FormattedMessage id='notifications.column_settings.mention' defaultMessage='Mentions:' />,
          }, {
            key: 'reblog',
            label: <FormattedMessage id='notifications.column_settings.reblog' defaultMessage='Boosts:' />,
          },
        ].map(({ key, label }, index) => {
          const labelId = `notifications-${index}`;
          const desktopSettingKey = ['alerts', key];
          const pushSettingKey = ['alerts', key];
          const showSettingKey = ['shows', key];
          const soundSettingkey = ['sounds', key];

          return (
            <div key={index} role='group' aria-labelledby={labelId}>
              <span id={labelId} className='column-settings__section'>{label}</span>

              <div className='column-settings__row'>
                {showDesktopSettings && <SettingToggle prefix='notifications_desktop' settings={settings} settingKey={desktopSettingKey} onChange={onChange} label={alertStr} />}
                {showPushSettings && <SettingToggle disabled={showDesktopSettings && !settings.getIn(desktopSettingKey)} sub={showDesktopSettings} prefix='notifications_push' settings={pushSettings} settingKey={pushSettingKey} meta={pushMeta} onChange={this.onPushChange} label={pushStr} />}
                <SettingToggle prefix='notifications' settings={settings} settingKey={showSettingKey} onChange={onChange} label={showStr} />
                <SettingToggle prefix='notifications' settings={settings} settingKey={soundSettingkey} onChange={onChange} label={soundStr} />
              </div>
            </div>
          );
        })}
      </div>
    );
  }

}

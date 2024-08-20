import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';

import { identityContextPropShape, withIdentity } from 'mastodon/identity_context';
import { PERMISSION_MANAGE_USERS, PERMISSION_MANAGE_REPORTS } from 'mastodon/permissions';

import ClearColumnButton from './clear_column_button';
import GrantPermissionButton from './grant_permission_button';
import { PolicyControls } from './policy_controls';
import SettingToggle from './setting_toggle';

class ColumnSettings extends PureComponent {
  static propTypes = {
    identity: identityContextPropShape,
    settings: ImmutablePropTypes.map.isRequired,
    pushSettings: ImmutablePropTypes.map.isRequired,
    onChange: PropTypes.func.isRequired,
    onClear: PropTypes.func.isRequired,
    onRequestNotificationPermission: PropTypes.func,
    alertsEnabled: PropTypes.bool,
    browserSupport: PropTypes.bool,
    browserPermission: PropTypes.string,
  };

  onPushChange = (path, checked) => {
    this.props.onChange(['push', ...path], checked);
  };

  render () {
    const { settings, pushSettings, onChange, onClear, alertsEnabled, browserSupport, browserPermission, onRequestNotificationPermission } = this.props;

    const filterAdvancedStr = <FormattedMessage id='notifications.column_settings.filter_bar.advanced' defaultMessage='Display all categories' />;
    const unreadMarkersShowStr = <FormattedMessage id='notifications.column_settings.unread_notifications.highlight' defaultMessage='Highlight unread notifications' />;
    const groupingShowStr = <FormattedMessage id='notifications.column_settings.beta.grouping' defaultMessage='Group notifications' />;
    const alertStr = <FormattedMessage id='notifications.column_settings.alert' defaultMessage='Desktop notifications' />;
    const showStr = <FormattedMessage id='notifications.column_settings.show' defaultMessage='Show in column' />;
    const soundStr = <FormattedMessage id='notifications.column_settings.sound' defaultMessage='Play sound' />;

    const showPushSettings = pushSettings.get('browserSupport') && pushSettings.get('isSubscribed');
    const pushStr = showPushSettings && <FormattedMessage id='notifications.column_settings.push' defaultMessage='Push notifications' />;

    return (
      <div className='column-settings'>
        <section>
          <ClearColumnButton onClick={onClear} />
        </section>

        {alertsEnabled && browserSupport && browserPermission === 'denied' && (
          <section>
            <span className='warning-hint'>
              <FormattedMessage id='notifications.permission_denied' defaultMessage='Desktop notifications are unavailable due to previously denied browser permissions request' />
            </span>
          </section>
        )}

        {alertsEnabled && browserSupport && browserPermission === 'default' && (
          <section>
            <span className='warning-hint'>
              <FormattedMessage id='notifications.permission_required' defaultMessage='Desktop notifications are unavailable because the required permission has not been granted.' /> <GrantPermissionButton onClick={onRequestNotificationPermission} />
            </span>
          </section>
        )}

        <PolicyControls />

        <section role='group' aria-labelledby='notifications-beta'>
          <h3 id='notifications-beta'>
            <FormattedMessage id='notifications.column_settings.beta.category' defaultMessage='Experimental features' />
          </h3>

          <div className='column-settings__row'>
            <SettingToggle id='unread-notification-markers' prefix='notifications' settings={settings} settingPath={['groupingBeta']} onChange={onChange} label={groupingShowStr} />
          </div>
        </section>

        <section role='group' aria-labelledby='notifications-unread-markers'>
          <h3 id='notifications-unread-markers'>
            <FormattedMessage id='notifications.column_settings.unread_notifications.category' defaultMessage='Unread notifications' />
          </h3>

          <div className='column-settings__row'>
            <SettingToggle id='unread-notification-markers' prefix='notifications' settings={settings} settingPath={['showUnread']} onChange={onChange} label={unreadMarkersShowStr} />
          </div>
        </section>

        <section role='group' aria-labelledby='notifications-filter-bar'>
          <h3 id='notifications-filter-bar'>
            <FormattedMessage id='notifications.column_settings.filter_bar.category' defaultMessage='Quick filter bar' />
          </h3>

          <div className='column-settings__row'>
            <SettingToggle id='advanced-filter-bar' prefix='notifications' settings={settings} settingPath={['quickFilter', 'advanced']} onChange={onChange} label={filterAdvancedStr} />
          </div>
        </section>

        <section role='group' aria-labelledby='notifications-follow'>
          <h3 id='notifications-follow'><FormattedMessage id='notifications.column_settings.follow' defaultMessage='New followers:' /></h3>

          <div className='column-settings__row'>
            <SettingToggle disabled={browserPermission === 'denied'} prefix='notifications_desktop' settings={settings} settingPath={['alerts', 'follow']} onChange={onChange} label={alertStr} />
            {showPushSettings && <SettingToggle prefix='notifications_push' settings={pushSettings} settingPath={['alerts', 'follow']} onChange={this.onPushChange} label={pushStr} />}
            <SettingToggle prefix='notifications' settings={settings} settingPath={['shows', 'follow']} onChange={onChange} label={showStr} />
            <SettingToggle prefix='notifications' settings={settings} settingPath={['sounds', 'follow']} onChange={onChange} label={soundStr} />
          </div>
        </section>

        <section role='group' aria-labelledby='notifications-follow-request'>
          <h3 id='notifications-follow-request'><FormattedMessage id='notifications.column_settings.follow_request' defaultMessage='New follow requests:' /></h3>

          <div className='column-settings__row'>
            <SettingToggle disabled={browserPermission === 'denied'} prefix='notifications_desktop' settings={settings} settingPath={['alerts', 'follow_request']} onChange={onChange} label={alertStr} />
            {showPushSettings && <SettingToggle prefix='notifications_push' settings={pushSettings} settingPath={['alerts', 'follow_request']} onChange={this.onPushChange} label={pushStr} />}
            <SettingToggle prefix='notifications' settings={settings} settingPath={['shows', 'follow_request']} onChange={onChange} label={showStr} />
            <SettingToggle prefix='notifications' settings={settings} settingPath={['sounds', 'follow_request']} onChange={onChange} label={soundStr} />
          </div>
        </section>

        <section role='group' aria-labelledby='notifications-favourite'>
          <h3 id='notifications-favourite'><FormattedMessage id='notifications.column_settings.favourite' defaultMessage='Favorites:' /></h3>

          <div className='column-settings__row'>
            <SettingToggle disabled={browserPermission === 'denied'} prefix='notifications_desktop' settings={settings} settingPath={['alerts', 'favourite']} onChange={onChange} label={alertStr} />
            {showPushSettings && <SettingToggle prefix='notifications_push' settings={pushSettings} settingPath={['alerts', 'favourite']} onChange={this.onPushChange} label={pushStr} />}
            <SettingToggle prefix='notifications' settings={settings} settingPath={['shows', 'favourite']} onChange={onChange} label={showStr} />
            <SettingToggle prefix='notifications' settings={settings} settingPath={['sounds', 'favourite']} onChange={onChange} label={soundStr} />
          </div>
        </section>

        <section role='group' aria-labelledby='notifications-mention'>
          <h3 id='notifications-mention'><FormattedMessage id='notifications.column_settings.mention' defaultMessage='Mentions:' /></h3>

          <div className='column-settings__row'>
            <SettingToggle disabled={browserPermission === 'denied'} prefix='notifications_desktop' settings={settings} settingPath={['alerts', 'mention']} onChange={onChange} label={alertStr} />
            {showPushSettings && <SettingToggle prefix='notifications_push' settings={pushSettings} settingPath={['alerts', 'mention']} onChange={this.onPushChange} label={pushStr} />}
            <SettingToggle prefix='notifications' settings={settings} settingPath={['shows', 'mention']} onChange={onChange} label={showStr} />
            <SettingToggle prefix='notifications' settings={settings} settingPath={['sounds', 'mention']} onChange={onChange} label={soundStr} />
          </div>
        </section>

        <section role='group' aria-labelledby='notifications-reblog'>
          <h3 id='notifications-reblog'><FormattedMessage id='notifications.column_settings.reblog' defaultMessage='Boosts:' /></h3>

          <div className='column-settings__row'>
            <SettingToggle disabled={browserPermission === 'denied'} prefix='notifications_desktop' settings={settings} settingPath={['alerts', 'reblog']} onChange={onChange} label={alertStr} />
            {showPushSettings && <SettingToggle prefix='notifications_push' settings={pushSettings} settingPath={['alerts', 'reblog']} onChange={this.onPushChange} label={pushStr} />}
            <SettingToggle prefix='notifications' settings={settings} settingPath={['shows', 'reblog']} onChange={onChange} label={showStr} />
            <SettingToggle prefix='notifications' settings={settings} settingPath={['sounds', 'reblog']} onChange={onChange} label={soundStr} />
          </div>
        </section>

        <section role='group' aria-labelledby='notifications-poll'>
          <h3 id='notifications-poll'><FormattedMessage id='notifications.column_settings.poll' defaultMessage='Poll results:' /></h3>

          <div className='column-settings__row'>
            <SettingToggle disabled={browserPermission === 'denied'} prefix='notifications_desktop' settings={settings} settingPath={['alerts', 'poll']} onChange={onChange} label={alertStr} />
            {showPushSettings && <SettingToggle prefix='notifications_push' settings={pushSettings} settingPath={['alerts', 'poll']} onChange={this.onPushChange} label={pushStr} />}
            <SettingToggle prefix='notifications' settings={settings} settingPath={['shows', 'poll']} onChange={onChange} label={showStr} />
            <SettingToggle prefix='notifications' settings={settings} settingPath={['sounds', 'poll']} onChange={onChange} label={soundStr} />
          </div>
        </section>

        <section role='group' aria-labelledby='notifications-status'>
          <h3 id='notifications-status'><FormattedMessage id='notifications.column_settings.status' defaultMessage='New posts:' /></h3>

          <div className='column-settings__row'>
            <SettingToggle disabled={browserPermission === 'denied'} prefix='notifications_desktop' settings={settings} settingPath={['alerts', 'status']} onChange={onChange} label={alertStr} />
            {showPushSettings && <SettingToggle prefix='notifications_push' settings={pushSettings} settingPath={['alerts', 'status']} onChange={this.onPushChange} label={pushStr} />}
            <SettingToggle prefix='notifications' settings={settings} settingPath={['shows', 'status']} onChange={onChange} label={showStr} />
            <SettingToggle prefix='notifications' settings={settings} settingPath={['sounds', 'status']} onChange={onChange} label={soundStr} />
          </div>
        </section>

        <section role='group' aria-labelledby='notifications-update'>
          <h3 id='notifications-update'><FormattedMessage id='notifications.column_settings.update' defaultMessage='Edits:' /></h3>

          <div className='column-settings__row'>
            <SettingToggle disabled={browserPermission === 'denied'} prefix='notifications_desktop' settings={settings} settingPath={['alerts', 'update']} onChange={onChange} label={alertStr} />
            {showPushSettings && <SettingToggle prefix='notifications_push' settings={pushSettings} settingPath={['alerts', 'update']} onChange={this.onPushChange} label={pushStr} />}
            <SettingToggle prefix='notifications' settings={settings} settingPath={['shows', 'update']} onChange={onChange} label={showStr} />
            <SettingToggle prefix='notifications' settings={settings} settingPath={['sounds', 'update']} onChange={onChange} label={soundStr} />
          </div>
        </section>

        {((this.props.identity.permissions & PERMISSION_MANAGE_USERS) === PERMISSION_MANAGE_USERS) && (
          <section role='group' aria-labelledby='notifications-admin-sign-up'>
            <h3 id='notifications-status'><FormattedMessage id='notifications.column_settings.admin.sign_up' defaultMessage='New sign-ups:' /></h3>

            <div className='column-settings__row'>
              <SettingToggle disabled={browserPermission === 'denied'} prefix='notifications_desktop' settings={settings} settingPath={['alerts', 'admin.sign_up']} onChange={onChange} label={alertStr} />
              {showPushSettings && <SettingToggle prefix='notifications_push' settings={pushSettings} settingPath={['alerts', 'admin.sign_up']} onChange={this.onPushChange} label={pushStr} />}
              <SettingToggle prefix='notifications' settings={settings} settingPath={['shows', 'admin.sign_up']} onChange={onChange} label={showStr} />
              <SettingToggle prefix='notifications' settings={settings} settingPath={['sounds', 'admin.sign_up']} onChange={onChange} label={soundStr} />
            </div>
          </section>
        )}

        {((this.props.identity.permissions & PERMISSION_MANAGE_REPORTS) === PERMISSION_MANAGE_REPORTS) && (
          <section role='group' aria-labelledby='notifications-admin-report'>
            <h3 id='notifications-status'><FormattedMessage id='notifications.column_settings.admin.report' defaultMessage='New reports:' /></h3>

            <div className='column-settings__row'>
              <SettingToggle disabled={browserPermission === 'denied'} prefix='notifications_desktop' settings={settings} settingPath={['alerts', 'admin.report']} onChange={onChange} label={alertStr} />
              {showPushSettings && <SettingToggle prefix='notifications_push' settings={pushSettings} settingPath={['alerts', 'admin.report']} onChange={this.onPushChange} label={pushStr} />}
              <SettingToggle prefix='notifications' settings={settings} settingPath={['shows', 'admin.report']} onChange={onChange} label={showStr} />
              <SettingToggle prefix='notifications' settings={settings} settingPath={['sounds', 'admin.report']} onChange={onChange} label={soundStr} />
            </div>
          </section>
        )}
      </div>
    );
  }

}

export default withIdentity(ColumnSettings);

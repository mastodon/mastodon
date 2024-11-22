import { defineMessages, injectIntl } from 'react-intl';

import { connect } from 'react-redux';

import { openModal } from 'mastodon/actions/modal';
import { initializeNotifications } from 'mastodon/actions/notifications_migration';

import { showAlert } from '../../../actions/alerts';
import { setFilter, requestBrowserPermission } from '../../../actions/notifications';
import { changeAlerts as changePushNotifications } from '../../../actions/push_notifications';
import { changeSetting } from '../../../actions/settings';
import ColumnSettings from '../components/column_settings';

const messages = defineMessages({
  permissionDenied: { id: 'notifications.permission_denied_alert', defaultMessage: 'Desktop notifications can\'t be enabled, as browser permission has been denied before' },
});

/**
 * @param {import('mastodon/store').RootState} state
 */
const mapStateToProps = state => ({
  settings: state.getIn(['settings', 'notifications']),
  pushSettings: state.get('push_notifications'),
  alertsEnabled: state.getIn(['settings', 'notifications', 'alerts']).includes(true),
  browserSupport: state.getIn(['notifications', 'browserSupport']),
  browserPermission: state.getIn(['notifications', 'browserPermission']),
});

const mapDispatchToProps = (dispatch) => ({

  onChange (path, checked) {
    if (path[0] === 'push') {
      if (checked && typeof window.Notification !== 'undefined' && Notification.permission !== 'granted') {
        dispatch(requestBrowserPermission((permission) => {
          if (permission === 'granted') {
            dispatch(changePushNotifications(path.slice(1), checked));
          } else {
            dispatch(showAlert({ message: messages.permissionDenied }));
          }
        }));
      } else {
        dispatch(changePushNotifications(path.slice(1), checked));
      }
    } else if (path[0] === 'quickFilter') {
      dispatch(changeSetting(['notifications', ...path], checked));
      dispatch(setFilter('all'));
    } else if (path[0] === 'alerts' && checked && typeof window.Notification !== 'undefined' && Notification.permission !== 'granted') {
      if (checked && typeof window.Notification !== 'undefined' && Notification.permission !== 'granted') {
        dispatch(requestBrowserPermission((permission) => {
          if (permission === 'granted') {
            dispatch(changeSetting(['notifications', ...path], checked));
          } else {
            dispatch(showAlert({ message: messages.permissionDenied }));
          }
        }));
      } else {
        dispatch(changeSetting(['notifications', ...path], checked));
      }
    } else {
      dispatch(changeSetting(['notifications', ...path], checked));

      if(path[0] === 'group' && path[1] === 'follow') {
        dispatch(initializeNotifications());
      }
    }
  },

  onClear () {
    dispatch(openModal({ modalType: 'CONFIRM_CLEAR_NOTIFICATIONS' }));
  },

  onRequestNotificationPermission () {
    dispatch(requestBrowserPermission());
  },

});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(ColumnSettings));

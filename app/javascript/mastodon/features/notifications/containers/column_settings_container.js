import { connect } from 'react-redux';
import { defineMessages, injectIntl } from 'react-intl';
import ColumnSettings from '../components/column_settings';
import { changeSetting } from '../../../actions/settings';
import { clearNotifications } from '../../../actions/notifications';
import { changeAlerts as changePushNotifications } from '../../../actions/push_notifications';
import { openModal } from '../../../actions/modal';

const messages = defineMessages({
  clearMessage: { id: 'notifications.clear_confirmation', defaultMessage: 'Are you sure you want to permanently clear all your notifications?' },
  clearConfirm: { id: 'notifications.clear', defaultMessage: 'Clear notifications' },
});

const mapStateToProps = state => ({
  settings: state.getIn(['settings', 'notifications']),
  pushSettings: state.get('push_notifications'),
});

const mapDispatchToProps = (dispatch, { intl }) => ({

  onChange (path, checked) {
    if (path[0] === 'push') {
      dispatch(changePushNotifications(path.slice(1), checked));
    } else {
      dispatch(changeSetting(['notifications', ...path], checked));
    }
  },

  onClear () {
    dispatch(openModal('CONFIRM', {
      message: intl.formatMessage(messages.clearMessage),
      confirm: intl.formatMessage(messages.clearConfirm),
      onConfirm: () => dispatch(clearNotifications()),
    }));
  },

});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(ColumnSettings));

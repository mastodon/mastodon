import { openModal } from 'flavours/glitch/actions/modal';
import { connect }   from 'react-redux';
import { defineMessages, injectIntl } from 'react-intl';
import Header from '../components/header';
import { logOut } from 'flavours/glitch/utils/log_out';

const messages = defineMessages({
  logoutMessage: { id: 'confirmations.logout.message', defaultMessage: 'Are you sure you want to log out?' },
  logoutConfirm: { id: 'confirmations.logout.confirm', defaultMessage: 'Log out' },
});

const mapStateToProps = state => {
  return {
    columns: state.getIn(['settings', 'columns']),
    unreadNotifications: state.getIn(['notifications', 'unread']),
    showNotificationsBadge: state.getIn(['local_settings', 'notifications', 'tab_badge']),
  };
};

const mapDispatchToProps = (dispatch, { intl }) => ({
  onSettingsClick (e) {
    e.preventDefault();
    e.stopPropagation();
    dispatch(openModal('SETTINGS', {}));
  },
  onLogout () {
    dispatch(openModal('CONFIRM', {
      message: intl.formatMessage(messages.logoutMessage),
      confirm: intl.formatMessage(messages.logoutConfirm),
      closeWhenConfirm: false,
      onConfirm: () => logOut(),
    }));
  },
});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(Header));

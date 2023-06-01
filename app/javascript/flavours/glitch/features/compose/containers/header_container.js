import { defineMessages, injectIntl } from 'react-intl';

import { connect }   from 'react-redux';

import { openModal } from 'flavours/glitch/actions/modal';
import { logOut } from 'flavours/glitch/utils/log_out';

import Header from '../components/header';

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
    dispatch(openModal({ modalType: 'SETTINGS', modalProps: {} }));
  },
  onLogout () {
    dispatch(openModal({
      modalType: 'CONFIRM',
      modalProps: {
        message: intl.formatMessage(messages.logoutMessage),
        confirm: intl.formatMessage(messages.logoutConfirm),
        closeWhenConfirm: false,
        onConfirm: () => logOut(),
      },
    }));
  },
});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(Header));

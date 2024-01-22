import { defineMessages, injectIntl } from 'react-intl';

import { connect }   from 'react-redux';

import { openModal } from 'mastodon/actions/modal';
import { logOut } from 'mastodon/utils/log_out';

import { me } from '../../../initial_state';
import NavigationBar from '../components/navigation_bar';

const messages = defineMessages({
  logoutMessage: { id: 'confirmations.logout.message', defaultMessage: 'Are you sure you want to log out?' },
  logoutConfirm: { id: 'confirmations.logout.confirm', defaultMessage: 'Log out' },
});

const mapStateToProps = state => {
  return {
    account: state.getIn(['accounts', me]),
  };
};

const mapDispatchToProps = (dispatch, { intl }) => ({
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

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(NavigationBar));

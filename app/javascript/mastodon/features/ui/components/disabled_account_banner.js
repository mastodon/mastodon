import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { Link } from 'react-router-dom';
import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';
import { disabledAccountId, movedToAccountId, domain } from 'mastodon/initial_state';
import { openModal } from 'mastodon/actions/modal';
import { logOut } from 'mastodon/utils/log_out';

const messages = defineMessages({
  logoutMessage: { id: 'confirmations.logout.message', defaultMessage: 'Are you sure you want to log out?' },
  logoutConfirm: { id: 'confirmations.logout.confirm', defaultMessage: 'Log out' },
});

const mapStateToProps = (state) => ({
  disabledAcct: state.getIn(['accounts', disabledAccountId, 'acct']),
  movedToAcct: movedToAccountId ? state.getIn(['accounts', movedToAccountId, 'acct']) : undefined,
});

const mapDispatchToProps = (dispatch, { intl }) => ({
  onLogout () {
    dispatch(openModal('CONFIRM', {
      message: intl.formatMessage(messages.logoutMessage),
      confirm: intl.formatMessage(messages.logoutConfirm),
      closeWhenConfirm: false,
      onConfirm: () => logOut(),
    }));
  },
});

export default @injectIntl
@connect(mapStateToProps, mapDispatchToProps)
class DisabledAccountBanner extends React.PureComponent {

  static propTypes = {
    disabledAcct: PropTypes.string.isRequired,
    movedToAcct: PropTypes.string,
    onLogout: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleLogOutClick = e => {
    e.preventDefault();
    e.stopPropagation();

    this.props.onLogout();

    return false;
  };

  render () {
    const { disabledAcct, movedToAcct } = this.props;

    const disabledAccountLink = (
      <Link to={`/@${disabledAcct}`}>
        {disabledAcct}@{domain}
      </Link>
    );

    return (
      <div className='sign-in-banner'>
        <p>
          {movedToAcct ? (
            <FormattedMessage
              id='moved_to_account_banner.text'
              defaultMessage='Your account {disabledAccount} is currently disabled because you moved to {movedToAccount}.'
              values={{
                disabledAccount: disabledAccountLink,
                movedToAccount: <Link to={`/@${movedToAcct}`}>{movedToAcct.includes('@') ? movedToAcct : `${movedToAcct}@${domain}`}</Link>,
              }}
            />
          ) : (
            <FormattedMessage
              id='disabled_account_banner.text'
              defaultMessage='Your account {disabledAccount} is currently disabled.'
              values={{
                disabledAccount: disabledAccountLink,
              }}
            />
          )}
        </p>
        <a href='/auth/edit' className='button button--block'>
          <FormattedMessage id='disabled_account_banner.account_settings' defaultMessage='Account settings' />
        </a>
        <button type='button' className='button button--block button-tertiary' onClick={this.handleLogOutClick}>
          <FormattedMessage id='confirmations.logout.confirm' defaultMessage='Log out' />
        </button>
      </div>
    );
  }

}

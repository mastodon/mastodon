import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage, injectIntl } from 'react-intl';

import { Link } from 'react-router-dom';

import { connect } from 'react-redux';

import { openModal } from 'mastodon/actions/modal';
import { disabledAccountId, movedToAccountId, domain } from 'mastodon/initial_state';

const mapStateToProps = (state) => ({
  disabledAcct: state.getIn(['accounts', disabledAccountId, 'acct']),
  movedToAcct: movedToAccountId ? state.getIn(['accounts', movedToAccountId, 'acct']) : undefined,
});

const mapDispatchToProps = (dispatch) => ({
  onLogout () {
    dispatch(openModal({ modalType: 'CONFIRM_LOG_OUT' }));
  },
});

class DisabledAccountBanner extends PureComponent {

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

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(DisabledAccountBanner));

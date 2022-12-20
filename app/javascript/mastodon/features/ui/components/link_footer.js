import { connect } from 'react-redux';
import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';
import { Link } from 'react-router-dom';
import { domain, version, source_url, profile_directory as profileDirectory } from 'mastodon/initial_state';
import { logOut } from 'mastodon/utils/log_out';
import { openModal } from 'mastodon/actions/modal';
import { PERMISSION_INVITE_USERS } from 'mastodon/permissions';

const messages = defineMessages({
  logoutMessage: { id: 'confirmations.logout.message', defaultMessage: 'Are you sure you want to log out?' },
  logoutConfirm: { id: 'confirmations.logout.confirm', defaultMessage: 'Log out' },
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
@connect(null, mapDispatchToProps)
class LinkFooter extends React.PureComponent {

  static contextTypes = {
    identity: PropTypes.object,
  };

  static propTypes = {
    onLogout: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleLogoutClick = e => {
    e.preventDefault();
    e.stopPropagation();

    this.props.onLogout();

    return false;
  }

  render () {
    const { signedIn, permissions } = this.context.identity;

    const canInvite = signedIn && ((permissions & PERMISSION_INVITE_USERS) === PERMISSION_INVITE_USERS);
    const canProfileDirectory = profileDirectory;

    return (
      <div className='link-footer'>
        <p>
          <strong>{domain}</strong>:
          {' '}
          <Link key='about' to='/about'><FormattedMessage id='footer.about' defaultMessage='About' /></Link>
          {canInvite && (
            <>
              <span aria-hidden>{' · '}</span>
              <a key='invites' href='/invites' target='_blank'><FormattedMessage id='footer.invite' defaultMessage='Invite people' /></a>
            </>
          )}
          {canProfileDirectory && (
            <>
              <span aria-hidden>{' · '}</span>
              <Link key='directory' to='/directory'><FormattedMessage id='footer.directory' defaultMessage='Profiles directory' /></Link>
            </>
          )}
          <span aria-hidden>{' · '}</span>
          <Link key='privacy-policy' to='/privacy-policy'><FormattedMessage id='footer.privacy_policy' defaultMessage='Privacy policy' /></Link>
        </p>

        <p>
          <strong>Mastodon</strong>:
          <span aria-hidden>{' · '}</span>
          <a href='https://joinmastodon.org' target='_blank'><FormattedMessage id='footer.about' defaultMessage='About' /></a>
          <span aria-hidden>{' · '}</span>
          <a href='https://joinmastodon.org/apps' target='_blank'><FormattedMessage id='footer.get_app' defaultMessage='Get the app' /></a>
          <span aria-hidden>{' · '}</span>
          <Link to='/keyboard-shortcuts'><FormattedMessage id='footer.keyboard_shortcuts' defaultMessage='Keyboard shortcuts' /></Link>
          <span aria-hidden>{' · '}</span>
          <a href={source_url} rel='noopener noreferrer' target='_blank'><FormattedMessage id='footer.source_code' defaultMessage='View source code' /></a>
          <span aria-hidden>{' · '}</span>
          v{version}
        </p>
      </div>
    );
  }

}

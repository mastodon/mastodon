import React from 'react';
import Image from 'mastodon/components/image';
import Logo from 'mastodon/components/logo';
import { Link, withRouter } from 'react-router-dom';
import { FormattedMessage } from 'react-intl';
import { registrationsOpen, me } from 'mastodon/initial_state';
import Avatar from 'mastodon/components/avatar';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

const Account = connect(state => ({
  account: state.getIn(['accounts', me]),
}))(({ account }) => (
  <Link to={`/@${account.get('acct')}`} title={account.get('acct')}>
    <Avatar account={account} size={35} />
  </Link>
));
const ServerLogo = connect(state => ({
  server: state.getIn(['server', 'server']),
}))(({ server }) => (
  (server.getIn(['logo', 'url']) === null) ? <Logo /> : <Image blurhash={server.getIn(['logo', 'blurhash'])} src={server.getIn(['logo', 'url'])} className='logo' />
));

export default @withRouter
class Header extends React.PureComponent {

  static contextTypes = {
    identity: PropTypes.object,
  };

  static propTypes = {
    location: PropTypes.object,
  };

  render () {
    const { signedIn } = this.context.identity;
    const { location } = this.props;

    let content;

    if (signedIn) {
      content = (
        <>
          {location.pathname !== '/publish' && <Link to='/publish' className='button'><FormattedMessage id='compose_form.publish' defaultMessage='Publish' /></Link>}
          <Account />
        </>
      );
    } else {
      content = (
        <>
          <a href='/auth/sign_in' className='button'><FormattedMessage id='sign_in_banner.sign_in' defaultMessage='Sign in' /></a>
          <a href={registrationsOpen ? '/auth/sign_up' : 'https://joinmastodon.org/servers'} className='button button-tertiary'><FormattedMessage id='sign_in_banner.create_account' defaultMessage='Create account' /></a>
        </>
      );
    }

    if (location.pathname === '/about') {
      return (<div className='about-header'>
        <header className='navbar'>
          <Link to='/'><ServerLogo /></Link>
        </header>
        <section className='navlinks'>
          <a href={process.env.APP_LINK} className='header-link'>{process.env.APP_LINK_TEXT}</a>
          <a href='/auth/sign_in' className='header-link'>Sign in</a>
          <div className='button-container'>
            <a href={process.env.JOIN_BUTTON_LINK} className='header-button'>
              <span>{process.env.JOIN_BUTTON_TEXT}</span>
            </a>
          </div>
        </section>
      </div>);
    } else {
      return (
        <div className='ui__header'>
          <Link to='/' className='ui__header__logo'><ServerLogo /></Link>

          <div className='ui__header__links'>
            {content}
          </div>
        </div>
      );
    }
  }

}

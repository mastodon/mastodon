import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { injectIntl, defineMessages } from 'react-intl';

import { Helmet } from 'react-helmet';
import { Link } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import PeopleIcon from '@/material-icons/400-24px/group.svg?react';
import HomeIcon from '@/material-icons/400-24px/home-fill.svg?react';
import LogoutIcon from '@/material-icons/400-24px/logout.svg?react';
import MenuIcon from '@/material-icons/400-24px/menu.svg?react';
import NotificationsIcon from '@/material-icons/400-24px/notifications-fill.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import SettingsIcon from '@/material-icons/400-24px/settings-fill.svg?react';
import { openModal } from 'mastodon/actions/modal';
import Column from 'mastodon/components/column';
import { Icon }  from 'mastodon/components/icon';

import elephantUIPlane from '../../../images/elephant_ui_plane.svg';
import { changeComposing, mountCompose, unmountCompose } from '../../actions/compose';
import { mascot } from '../../initial_state';
import { isMobile } from '../../is_mobile';

import { Search } from './components/search';
import ComposeFormContainer from './containers/compose_form_container';

const messages = defineMessages({
  start: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
  home_timeline: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: { id: 'tabs_bar.notifications', defaultMessage: 'Notifications' },
  public: { id: 'navigation_bar.public_timeline', defaultMessage: 'Federated timeline' },
  community: { id: 'navigation_bar.community_timeline', defaultMessage: 'Local timeline' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  logout: { id: 'navigation_bar.logout', defaultMessage: 'Logout' },
  compose: { id: 'navigation_bar.compose', defaultMessage: 'Compose new post' },
});

const mapStateToProps = (state) => ({
  columns: state.getIn(['settings', 'columns']),
});

class Compose extends PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    columns: ImmutablePropTypes.list.isRequired,
    multiColumn: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(mountCompose());
  }

  componentWillUnmount () {
    const { dispatch } = this.props;
    dispatch(unmountCompose());
  }

  handleLogoutClick = e => {
    const { dispatch } = this.props;

    e.preventDefault();
    e.stopPropagation();

    dispatch(openModal({ modalType: 'CONFIRM_LOG_OUT' }));

    return false;
  };

  onFocus = () => {
    this.props.dispatch(changeComposing(true));
  };

  onBlur = () => {
    this.props.dispatch(changeComposing(false));
  };

  render () {
    const { multiColumn, intl } = this.props;

    if (multiColumn) {
      const { columns } = this.props;

      return (
        <div className='drawer' role='region' aria-label={intl.formatMessage(messages.compose)}>
          <nav className='drawer__header'>
            <Link to='/getting-started' className='drawer__tab' title={intl.formatMessage(messages.start)} aria-label={intl.formatMessage(messages.start)}><Icon id='bars' icon={MenuIcon} /></Link>
            {!columns.some(column => column.get('id') === 'HOME') && (
              <Link to='/home' className='drawer__tab' title={intl.formatMessage(messages.home_timeline)} aria-label={intl.formatMessage(messages.home_timeline)}><Icon id='home' icon={HomeIcon} /></Link>
            )}
            {!columns.some(column => column.get('id') === 'NOTIFICATIONS') && (
              <Link to='/notifications' className='drawer__tab' title={intl.formatMessage(messages.notifications)} aria-label={intl.formatMessage(messages.notifications)}><Icon id='bell' icon={NotificationsIcon} /></Link>
            )}
            {!columns.some(column => column.get('id') === 'COMMUNITY') && (
              <Link to='/public/local' className='drawer__tab' title={intl.formatMessage(messages.community)} aria-label={intl.formatMessage(messages.community)}><Icon id='users' icon={PeopleIcon} /></Link>
            )}
            {!columns.some(column => column.get('id') === 'PUBLIC') && (
              <Link to='/public' className='drawer__tab' title={intl.formatMessage(messages.public)} aria-label={intl.formatMessage(messages.public)}><Icon id='globe' icon={PublicIcon} /></Link>
            )}
            <a href='/settings/preferences' className='drawer__tab' title={intl.formatMessage(messages.preferences)} aria-label={intl.formatMessage(messages.preferences)}><Icon id='cog' icon={SettingsIcon} /></a>
            <a href='/auth/sign_out' className='drawer__tab' title={intl.formatMessage(messages.logout)} aria-label={intl.formatMessage(messages.logout)} onClick={this.handleLogoutClick}><Icon id='sign-out' icon={LogoutIcon} /></a>
          </nav>

          {multiColumn && <Search /> }

          <div className='drawer__pager'>
            <div className='drawer__inner' onFocus={this.onFocus}>
              <ComposeFormContainer autoFocus={!isMobile(window.innerWidth)} />

              <div className='drawer__inner__mastodon'>
                <img alt='' draggable='false' src={mascot || elephantUIPlane} />
              </div>
            </div>
          </div>
        </div>
      );
    }

    return (
      <Column onFocus={this.onFocus}>
        <ComposeFormContainer />

        <Helmet>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(Compose));

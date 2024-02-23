import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { injectIntl, defineMessages } from 'react-intl';

import { Helmet } from 'react-helmet';
import { Link } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import spring from 'react-motion/lib/spring';

import PeopleIcon from '@/material-icons/400-24px/group.svg?react';
import HomeIcon from '@/material-icons/400-24px/home-fill.svg?react';
import LogoutIcon from '@/material-icons/400-24px/logout.svg?react';
import ManufacturingIcon from '@/material-icons/400-24px/manufacturing-fill.svg?react';
import MenuIcon from '@/material-icons/400-24px/menu.svg?react';
import NotificationsIcon from '@/material-icons/400-24px/notifications-fill.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import { openModal } from 'flavours/glitch/actions/modal';
import Column from 'flavours/glitch/components/column';
import { Icon }  from 'flavours/glitch/components/icon';
import glitchedElephant1 from 'flavours/glitch/images/mbstobon-ui-0.png';
import glitchedElephant2 from 'flavours/glitch/images/mbstobon-ui-1.png';
import glitchedElephant3 from 'flavours/glitch/images/mbstobon-ui-2.png';
import { logOut } from 'flavours/glitch/utils/log_out';

import elephantUIPlane from '../../../../images/elephant_ui_plane.svg';
import { changeComposing, mountCompose, unmountCompose } from '../../actions/compose';
import { mascot } from '../../initial_state';
import { isMobile } from '../../is_mobile';
import Motion from '../ui/util/optional_motion';

import ComposeFormContainer from './containers/compose_form_container';
import SearchContainer from './containers/search_container';
import SearchResultsContainer from './containers/search_results_container';

const messages = defineMessages({
  start: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
  home_timeline: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: { id: 'tabs_bar.notifications', defaultMessage: 'Notifications' },
  public: { id: 'navigation_bar.public_timeline', defaultMessage: 'Federated timeline' },
  community: { id: 'navigation_bar.community_timeline', defaultMessage: 'Local timeline' },
  settings: { id: 'navigation_bar.app_settings', defaultMessage: 'App settings' },
  logout: { id: 'navigation_bar.logout', defaultMessage: 'Logout' },
  compose: { id: 'navigation_bar.compose', defaultMessage: 'Compose new post' },
  logoutMessage: { id: 'confirmations.logout.message', defaultMessage: 'Are you sure you want to log out?' },
  logoutConfirm: { id: 'confirmations.logout.confirm', defaultMessage: 'Log out' },
});

const mapStateToProps = (state, ownProps) => ({
  columns: state.getIn(['settings', 'columns']),
  showSearch: ownProps.multiColumn ? state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']) : false,
  unreadNotifications: state.getIn(['notifications', 'unread']),
  showNotificationsBadge: state.getIn(['local_settings', 'notifications', 'tab_badge']),
});

// ~4% chance you'll end up with an unexpected friend
// glitch-soc/mastodon repo created_at date: 2017-04-20T21:55:28Z
const glitchProbability = 1 - 0.0420215528;
const totalElefriends = 3;

class Compose extends PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    columns: ImmutablePropTypes.list.isRequired,
    multiColumn: PropTypes.bool,
    showSearch: PropTypes.bool,
    unreadNotifications: PropTypes.number,
    showNotificationsBadge: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  state = {
    elefriend: Math.random() < glitchProbability ? Math.floor(Math.random() * totalElefriends) : totalElefriends,
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
    const { dispatch, intl } = this.props;

    e.preventDefault();
    e.stopPropagation();

    dispatch(openModal({
      modalType: 'CONFIRM',
      modalProps: {
        message: intl.formatMessage(messages.logoutMessage),
        confirm: intl.formatMessage(messages.logoutConfirm),
        closeWhenConfirm: false,
        onConfirm: () => logOut(),
      },
    }));

    return false;
  };

  handleSettingsClick = e => {
    const { dispatch } = this.props;

    e.preventDefault();
    e.stopPropagation();

    dispatch(openModal({ modalType: 'SETTINGS', modalProps: {} }));
  };

  onFocus = () => {
    this.props.dispatch(changeComposing(true));
  };

  onBlur = () => {
    this.props.dispatch(changeComposing(false));
  };

  cycleElefriend = () => {
    this.setState((state) => ({ elefriend: (state.elefriend + 1) % totalElefriends }));
  };

  render () {
    const { multiColumn, showSearch, showNotificationsBadge, unreadNotifications, intl } = this.props;

    const elefriend = [glitchedElephant1, glitchedElephant2, glitchedElephant3, elephantUIPlane][this.state.elefriend];

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
              <Link to='/notifications' className='drawer__tab' title={intl.formatMessage(messages.notifications)} aria-label={intl.formatMessage(messages.notifications)}>
                <span className='icon-badge-wrapper'>
                  <Icon id='bell' icon={NotificationsIcon} />
                  {showNotificationsBadge && unreadNotifications > 0 && <div className='icon-badge' />}
                </span>
              </Link>
            )}
            {!columns.some(column => column.get('id') === 'COMMUNITY') && (
              <Link to='/public/local' className='drawer__tab' title={intl.formatMessage(messages.community)} aria-label={intl.formatMessage(messages.community)}><Icon id='users' icon={PeopleIcon} /></Link>
            )}
            {!columns.some(column => column.get('id') === 'PUBLIC') && (
              <Link to='/public' className='drawer__tab' title={intl.formatMessage(messages.public)} aria-label={intl.formatMessage(messages.public)}><Icon id='globe' icon={PublicIcon} /></Link>
            )}
            <a
              onClick={this.handleSettingsClick}
              href='/settings/preferences'
              className='drawer__tab'
              title={intl.formatMessage(messages.settings)}
              aria-label={intl.formatMessage(messages.settings)}
            >
              <Icon id='cogs' icon={ManufacturingIcon} />
            </a>
            <a href='/auth/sign_out' className='drawer__tab' title={intl.formatMessage(messages.logout)} aria-label={intl.formatMessage(messages.logout)} onClick={this.handleLogoutClick}><Icon id='sign-out' icon={LogoutIcon} /></a>
          </nav>

          {multiColumn && <SearchContainer /> }

          <div className='drawer__pager'>
            <div className='drawer__inner' onFocus={this.onFocus}>
              <ComposeFormContainer autoFocus={!isMobile(window.innerWidth)} />

              {/* eslint-disable-next-line jsx-a11y/no-static-element-interactions -- this is not a feature but a visual easter egg */}
              <div className='drawer__inner__mastodon' onClick={this.cycleElefriend}>
                <img alt='' draggable='false' src={mascot || elefriend} />
              </div>
            </div>

            <Motion defaultStyle={{ x: -100 }} style={{ x: spring(showSearch ? 0 : -100, { stiffness: 210, damping: 20 }) }}>
              {({ x }) => (
                <div className='drawer__inner darker' style={{ transform: `translateX(${x}%)`, visibility: x === -100 ? 'hidden' : 'visible' }}>
                  <SearchResultsContainer />
                </div>
              )}
            </Motion>
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

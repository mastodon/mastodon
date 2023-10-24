import PropTypes from 'prop-types';

import { injectIntl, defineMessages } from 'react-intl';

import { Link } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { ReactComponent as PeopleIcon } from '@material-symbols/svg-600/outlined/group.svg';
import { ReactComponent as HomeIcon } from '@material-symbols/svg-600/outlined/home-fill.svg';
import { ReactComponent as LogoutIcon } from '@material-symbols/svg-600/outlined/logout.svg';
import { ReactComponent as ManufacturingIcon } from '@material-symbols/svg-600/outlined/manufacturing.svg';
import { ReactComponent as MenuIcon } from '@material-symbols/svg-600/outlined/menu.svg';
import { ReactComponent as NotificationsIcon } from '@material-symbols/svg-600/outlined/notifications-fill.svg';
import { ReactComponent as PublicIcon } from '@material-symbols/svg-600/outlined/public.svg';

import { Icon } from 'flavours/glitch/components/icon';
import { signOutLink } from 'flavours/glitch/utils/backend_links';
import { conditionalRender } from 'flavours/glitch/utils/react_helpers';

const messages = defineMessages({
  community: {
    defaultMessage: 'Local timeline',
    id: 'navigation_bar.community_timeline',
  },
  home_timeline: {
    defaultMessage: 'Home',
    id: 'tabs_bar.home',
  },
  logout: {
    defaultMessage: 'Logout',
    id: 'navigation_bar.logout',
  },
  notifications: {
    defaultMessage: 'Notifications',
    id: 'tabs_bar.notifications',
  },
  public: {
    defaultMessage: 'Federated timeline',
    id: 'navigation_bar.public_timeline',
  },
  settings: {
    defaultMessage: 'App settings',
    id: 'navigation_bar.app_settings',
  },
  start: {
    defaultMessage: 'Getting started',
    id: 'getting_started.heading',
  },
});

class Header extends ImmutablePureComponent {

  static propTypes = {
    columns: ImmutablePropTypes.list,
    unreadNotifications: PropTypes.number,
    showNotificationsBadge: PropTypes.bool,
    intl: PropTypes.object,
    onSettingsClick: PropTypes.func,
    onLogout: PropTypes.func.isRequired,
  };

  handleLogoutClick = e => {
    e.preventDefault();
    e.stopPropagation();

    this.props.onLogout();

    return false;
  };

  render () {
    const { intl, columns, unreadNotifications, showNotificationsBadge, onSettingsClick } = this.props;

    //  Only renders the component if the column isn't being shown.
    const renderForColumn = conditionalRender.bind(null,
      columnId => !columns || !columns.some(
        column => column.get('id') === columnId,
      ),
    );

    //  The result.
    return (
      <nav className='drawer__header'>
        <Link
          aria-label={intl.formatMessage(messages.start)}
          title={intl.formatMessage(messages.start)}
          to='/getting-started'
          className='drawer__tab'
        ><Icon id='bars' icon={MenuIcon} /></Link>
        {renderForColumn('HOME', (
          <Link
            aria-label={intl.formatMessage(messages.home_timeline)}
            title={intl.formatMessage(messages.home_timeline)}
            to='/home'
            className='drawer__tab'
          ><Icon id='home' icon={HomeIcon} /></Link>
        ))}
        {renderForColumn('NOTIFICATIONS', (
          <Link
            aria-label={intl.formatMessage(messages.notifications)}
            title={intl.formatMessage(messages.notifications)}
            to='/notifications'
            className='drawer__tab'
          >
            <span className='icon-badge-wrapper'>
              <Icon id='bell' icon={NotificationsIcon} />
              { showNotificationsBadge && unreadNotifications > 0 && <div className='icon-badge' />}
            </span>
          </Link>
        ))}
        {renderForColumn('COMMUNITY', (
          <Link
            aria-label={intl.formatMessage(messages.community)}
            title={intl.formatMessage(messages.community)}
            to='/public/local'
            className='drawer__tab'
          ><Icon id='users' icon={PeopleIcon} /></Link>
        ))}
        {renderForColumn('PUBLIC', (
          <Link
            aria-label={intl.formatMessage(messages.public)}
            title={intl.formatMessage(messages.public)}
            to='/public'
            className='drawer__tab'
          ><Icon id='globe' icon={PublicIcon} /></Link>
        ))}
        <a
          aria-label={intl.formatMessage(messages.settings)}
          onClick={onSettingsClick}
          href='/settings/preferences'
          title={intl.formatMessage(messages.settings)}
          className='drawer__tab'
        ><Icon id='cogs' icon={ManufacturingIcon} /></a>
        <a
          aria-label={intl.formatMessage(messages.logout)}
          onClick={this.handleLogoutClick}
          href={signOutLink}
          title={intl.formatMessage(messages.logout)}
          className='drawer__tab'
        ><Icon id='sign-out' icon={LogoutIcon} /></a>
      </nav>
    );
  }

}

export default injectIntl(Header);

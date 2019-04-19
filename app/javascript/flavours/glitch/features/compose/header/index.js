//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages } from 'react-intl';
import { Link } from 'react-router-dom';

//  Components.
import Icon from 'flavours/glitch/components/icon';

//  Utils.
import { conditionalRender } from 'flavours/glitch/util/react_helpers';
import { signOutLink } from 'flavours/glitch/util/backend_links';

//  Messages.
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

//  The component.
export default function DrawerHeader ({
  columns,
  unreadNotifications,
  showNotificationsBadge,
  intl,
  onSettingsClick,
}) {

  //  Only renders the component if the column isn't being shown.
  const renderForColumn = conditionalRender.bind(null,
    columnId => !columns || !columns.some(
      column => column.get('id') === columnId
    )
  );

  //  The result.
  return (
    <nav className='drawer--header'>
      <Link
        aria-label={intl.formatMessage(messages.start)}
        title={intl.formatMessage(messages.start)}
        to='/getting-started'
      ><Icon icon='asterisk' /></Link>
      {renderForColumn('HOME', (
        <Link
          aria-label={intl.formatMessage(messages.home_timeline)}
          title={intl.formatMessage(messages.home_timeline)}
          to='/timelines/home'
        ><Icon icon='home' /></Link>
      ))}
      {renderForColumn('NOTIFICATIONS', (
        <Link
          aria-label={intl.formatMessage(messages.notifications)}
          title={intl.formatMessage(messages.notifications)}
          to='/notifications'
        >
          <span className='icon-badge-wrapper'>
            <Icon icon='bell' />
            { showNotificationsBadge && unreadNotifications > 0 && <div className='icon-badge' />}
          </span>
        </Link>
      ))}
      {renderForColumn('COMMUNITY', (
        <Link
          aria-label={intl.formatMessage(messages.community)}
          title={intl.formatMessage(messages.community)}
          to='/timelines/public/local'
        ><Icon icon='users' /></Link>
      ))}
      {renderForColumn('PUBLIC', (
        <Link
          aria-label={intl.formatMessage(messages.public)}
          title={intl.formatMessage(messages.public)}
          to='/timelines/public'
        ><Icon icon='globe' /></Link>
      ))}
      <a
        aria-label={intl.formatMessage(messages.settings)}
        onClick={onSettingsClick}
        href='#'
        title={intl.formatMessage(messages.settings)}
      ><Icon icon='cogs' /></a>
      <a
        aria-label={intl.formatMessage(messages.logout)}
        data-method='delete'
        href={ signOutLink }
        title={intl.formatMessage(messages.logout)}
      ><Icon icon='sign-out' /></a>
    </nav>
  );
}

//  Props.
DrawerHeader.propTypes = {
  columns: ImmutablePropTypes.list,
  unreadNotifications: PropTypes.number,
  showNotificationsBadge: PropTypes.bool,
  intl: PropTypes.object,
  onSettingsClick: PropTypes.func,
};

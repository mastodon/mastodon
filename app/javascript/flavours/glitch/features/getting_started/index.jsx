import PropTypes from 'prop-types';

import { defineMessages, injectIntl } from 'react-intl';

import { Helmet } from 'react-helmet';

import { createSelector } from '@reduxjs/toolkit';
import { List as ImmutableList } from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import BookmarksIcon from '@/material-icons/400-24px/bookmarks-fill.svg?react';
import ExploreIcon from '@/material-icons/400-24px/explore.svg?react';
import PeopleIcon from '@/material-icons/400-24px/group.svg?react';
import HomeIcon from '@/material-icons/400-24px/home-fill.svg?react';
import ListAltIcon from '@/material-icons/400-24px/list_alt.svg?react';
import MailIcon from '@/material-icons/400-24px/mail.svg?react';
import ManufacturingIcon from '@/material-icons/400-24px/manufacturing.svg?react';
import MenuIcon from '@/material-icons/400-24px/menu.svg?react';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import NotificationsIcon from '@/material-icons/400-24px/notifications.svg?react';
import PersonAddIcon from '@/material-icons/400-24px/person_add.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import SettingsIcon from '@/material-icons/400-24px/settings-fill.svg?react';
import { fetchFollowRequests } from 'flavours/glitch/actions/accounts';
import { fetchLists } from 'flavours/glitch/actions/lists';
import { openModal } from 'flavours/glitch/actions/modal';
import Column from 'flavours/glitch/features/ui/components/column';
import LinkFooter from 'flavours/glitch/features/ui/components/link_footer';
import { identityContextPropShape, withIdentity } from 'flavours/glitch/identity_context';
import { preferencesLink } from 'flavours/glitch/utils/backend_links';


import { me, showTrends } from '../../initial_state';
import { NavigationBar } from '../compose/components/navigation_bar';
import ColumnLink from '../ui/components/column_link';
import ColumnSubheading from '../ui/components/column_subheading';

import TrendsContainer from './containers/trends_container';

const messages = defineMessages({
  heading: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
  home_timeline: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: { id: 'tabs_bar.notifications', defaultMessage: 'Notifications' },
  public_timeline: { id: 'navigation_bar.public_timeline', defaultMessage: 'Federated timeline' },
  navigation_subheading: { id: 'column_subheading.navigation', defaultMessage: 'Navigation' },
  settings_subheading: { id: 'column_subheading.settings', defaultMessage: 'Settings' },
  community_timeline: { id: 'navigation_bar.community_timeline', defaultMessage: 'Local timeline' },
  explore: { id: 'navigation_bar.explore', defaultMessage: 'Explore' },
  direct: { id: 'navigation_bar.direct', defaultMessage: 'Private mentions' },
  bookmarks: { id: 'navigation_bar.bookmarks', defaultMessage: 'Bookmarks' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  settings: { id: 'navigation_bar.app_settings', defaultMessage: 'App settings' },
  follow_requests: { id: 'navigation_bar.follow_requests', defaultMessage: 'Follow requests' },
  lists: { id: 'navigation_bar.lists', defaultMessage: 'Lists' },
  keyboard_shortcuts: { id: 'navigation_bar.keyboard_shortcuts', defaultMessage: 'Keyboard shortcuts' },
  lists_subheading: { id: 'column_subheading.lists', defaultMessage: 'Lists' },
  misc: { id: 'navigation_bar.misc', defaultMessage: 'Misc' },
  menu: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
});

const makeMapStateToProps = () => {
  const getOrderedLists = createSelector([state => state.get('lists')], lists => {
    if (!lists) {
      return lists;
    }

    return lists.toList().filter(item => !!item).sort((a, b) => a.get('title').localeCompare(b.get('title')));
  });

  const mapStateToProps = state => ({
    lists: getOrderedLists(state),
    myAccount: state.getIn(['accounts', me]),
    columns: state.getIn(['settings', 'columns']),
    unreadFollowRequests: state.getIn(['user_lists', 'follow_requests', 'items'], ImmutableList()).size,
    unreadNotifications: state.getIn(['notifications', 'unread']),
  });

  return mapStateToProps;
};

const mapDispatchToProps = dispatch => ({
  fetchFollowRequests: () => dispatch(fetchFollowRequests()),
  fetchLists: () => dispatch(fetchLists()),
  openSettings: () => dispatch(openModal({
    modalType: 'SETTINGS',
    modalProps: {},
  })),
});

const badgeDisplay = (number, limit) => {
  if (number === 0) {
    return undefined;
  } else if (limit && number >= limit) {
    return `${limit}+`;
  } else {
    return number;
  }
};

class GettingStarted extends ImmutablePureComponent {
  static propTypes = {
    identity: identityContextPropShape,
    intl: PropTypes.object.isRequired,
    myAccount: ImmutablePropTypes.record,
    columns: ImmutablePropTypes.list,
    multiColumn: PropTypes.bool,
    fetchFollowRequests: PropTypes.func.isRequired,
    unreadFollowRequests: PropTypes.number,
    unreadNotifications: PropTypes.number,
    lists: ImmutablePropTypes.list,
    fetchLists: PropTypes.func.isRequired,
    openSettings: PropTypes.func.isRequired,
  };

  UNSAFE_componentWillMount () {
    this.props.fetchLists();
  }

  componentDidMount () {
    const { fetchFollowRequests } = this.props;
    const { signedIn } = this.props.identity;

    if (!signedIn) {
      return;
    }

    fetchFollowRequests();
  }

  render () {
    const { intl, myAccount, columns, multiColumn, unreadFollowRequests, unreadNotifications, lists, openSettings } = this.props;
    const { signedIn } = this.props.identity;

    const navItems = [];
    let listItems = [];

    if (multiColumn) {
      if (signedIn && !columns.find(item => item.get('id') === 'HOME')) {
        navItems.push(<ColumnLink key='home' icon='home' iconComponent={HomeIcon} text={intl.formatMessage(messages.home_timeline)} to='/home' />);
      }

      if (!columns.find(item => item.get('id') === 'NOTIFICATIONS')) {
        navItems.push(<ColumnLink key='notifications' icon='bell' iconComponent={NotificationsIcon} text={intl.formatMessage(messages.notifications)} badge={badgeDisplay(unreadNotifications)} to='/notifications' />);
      }

      if (!columns.find(item => item.get('id') === 'COMMUNITY')) {
        navItems.push(<ColumnLink key='community_timeline' icon='users' iconComponent={PeopleIcon} text={intl.formatMessage(messages.community_timeline)} to='/public/local' />);
      }

      if (!columns.find(item => item.get('id') === 'PUBLIC')) {
        navItems.push(<ColumnLink key='public_timeline' icon='globe' iconComponent={PublicIcon} text={intl.formatMessage(messages.public_timeline)} to='/public' />);
      }
    }

    if (showTrends) {
      navItems.push(<ColumnLink key='explore' icon='explore' iconComponent={ExploreIcon} text={intl.formatMessage(messages.explore)} to='/explore' />);
    }

    if (signedIn) {
      if (!multiColumn || !columns.find(item => item.get('id') === 'DIRECT')) {
        navItems.push(<ColumnLink key='conversations' icon='envelope' iconComponent={MailIcon} text={intl.formatMessage(messages.direct)} to='/conversations' />);
      }

      if (!multiColumn || !columns.find(item => item.get('id') === 'BOOKMARKS')) {
        navItems.push(<ColumnLink key='bookmarks' icon='bookmark' iconComponent={BookmarksIcon} text={intl.formatMessage(messages.bookmarks)} to='/bookmarks' />);
      }

      if (myAccount.get('locked') || unreadFollowRequests > 0) {
        navItems.push(<ColumnLink key='follow_requests' icon='user-plus' iconComponent={PersonAddIcon} text={intl.formatMessage(messages.follow_requests)} badge={badgeDisplay(unreadFollowRequests, 40)} to='/follow_requests' />);
      }

      navItems.push(<ColumnLink key='getting_started' icon='ellipsis-h' iconComponent={MoreHorizIcon} text={intl.formatMessage(messages.misc)} to='/getting-started-misc' />);

      listItems = listItems.concat([
        <div key='9'>
          <ColumnLink key='lists' icon='bars' iconComponent={ListAltIcon} text={intl.formatMessage(messages.lists)} to='/lists' />
          {lists.filter(list => !columns.find(item => item.get('id') === 'LIST' && item.getIn(['params', 'id']) === list.get('id'))).map(list =>
            <ColumnLink key={`list-${list.get('id')}`} to={`/lists/${list.get('id')}`} icon='list-ul' iconComponent={ListAltIcon} text={list.get('title')} />,
          )}
        </div>,
      ]);
    }

    return (
      <Column bindToDocument={!multiColumn} icon='bars' iconComponent={MenuIcon} heading={intl.formatMessage(messages.heading)} label={intl.formatMessage(messages.menu)} hideHeadingOnMobile>
        <div className='scrollable optionally-scrollable'>
          <div className='getting-started__wrapper'>
            {!multiColumn && signedIn && <NavigationBar account={myAccount} />}
            {multiColumn && <ColumnSubheading text={intl.formatMessage(messages.navigation_subheading)} />}
            {navItems}
            {signedIn && (
              <>
                <ColumnSubheading text={intl.formatMessage(messages.lists_subheading)} />
                {listItems}
                <ColumnSubheading text={intl.formatMessage(messages.settings_subheading)} />
                { preferencesLink !== undefined && <ColumnLink icon='cog' iconComponent={SettingsIcon} text={intl.formatMessage(messages.preferences)} href={preferencesLink} /> }
                <ColumnLink icon='cogs' iconComponent={ManufacturingIcon} text={intl.formatMessage(messages.settings)} onClick={openSettings} />
              </>
            )}
          </div>

          <LinkFooter multiColumn />
        </div>

        {(multiColumn && showTrends) && <TrendsContainer />}

        <Helmet>
          <title>{intl.formatMessage(messages.menu)}</title>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default withIdentity(connect(makeMapStateToProps, mapDispatchToProps)(injectIntl(GettingStarted)));

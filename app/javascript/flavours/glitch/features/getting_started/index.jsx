import PropTypes from 'prop-types';

import { defineMessages, injectIntl } from 'react-intl';

import { Helmet } from 'react-helmet';

import { List as ImmutableList } from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';
import { createSelector } from 'reselect';

import { fetchFollowRequests } from 'flavours/glitch/actions/accounts';
import { fetchLists } from 'flavours/glitch/actions/lists';
import { openModal } from 'flavours/glitch/actions/modal';
import Column from 'flavours/glitch/features/ui/components/column';
import ColumnLink from 'flavours/glitch/features/ui/components/column_link';
import ColumnSubheading from 'flavours/glitch/features/ui/components/column_subheading';
import LinkFooter from 'flavours/glitch/features/ui/components/link_footer';
import { me, showTrends } from 'flavours/glitch/initial_state';
import { preferencesLink } from 'flavours/glitch/utils/backend_links';

import NavigationBar from '../compose/components/navigation_bar';

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
  direct: { id: 'navigation_bar.direct', defaultMessage: 'Direct messages' },
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

  static contextTypes = {
    router: PropTypes.object.isRequired,
    identity: PropTypes.object,
  };

  static propTypes = {
    intl: PropTypes.object.isRequired,
    myAccount: ImmutablePropTypes.map,
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
    const { signedIn } = this.context.identity;

    if (!signedIn) {
      return;
    }

    fetchFollowRequests();
  }

  render () {
    const { intl, myAccount, columns, multiColumn, unreadFollowRequests, unreadNotifications, lists, openSettings } = this.props;
    const { signedIn } = this.context.identity;

    const navItems = [];
    let listItems = [];

    if (multiColumn) {
      if (signedIn && !columns.find(item => item.get('id') === 'HOME')) {
        navItems.push(<ColumnLink key='home' icon='home' text={intl.formatMessage(messages.home_timeline)} to='/home' />);
      }

      if (!columns.find(item => item.get('id') === 'NOTIFICATIONS')) {
        navItems.push(<ColumnLink key='notifications' icon='bell' text={intl.formatMessage(messages.notifications)} badge={badgeDisplay(unreadNotifications)} to='/notifications' />);
      }

      if (!columns.find(item => item.get('id') === 'COMMUNITY')) {
        navItems.push(<ColumnLink key='community_timeline' icon='users' text={intl.formatMessage(messages.community_timeline)} to='/public/local' />);
      }

      if (!columns.find(item => item.get('id') === 'PUBLIC')) {
        navItems.push(<ColumnLink key='public_timeline' icon='globe' text={intl.formatMessage(messages.public_timeline)} to='/public' />);
      }
    }

    if (showTrends) {
      navItems.push(<ColumnLink key='explore' icon='hashtag' text={intl.formatMessage(messages.explore)} to='/explore' />);
    }

    if (signedIn) {
      if (!multiColumn || !columns.find(item => item.get('id') === 'DIRECT')) {
        navItems.push(<ColumnLink key='conversations' icon='envelope' text={intl.formatMessage(messages.direct)} to='/conversations' />);
      }

      if (!multiColumn || !columns.find(item => item.get('id') === 'BOOKMARKS')) {
        navItems.push(<ColumnLink key='bookmarks' icon='bookmark' text={intl.formatMessage(messages.bookmarks)} to='/bookmarks' />);
      }

      if (myAccount.get('locked') || unreadFollowRequests > 0) {
        navItems.push(<ColumnLink key='follow_requests' icon='user-plus' text={intl.formatMessage(messages.follow_requests)} badge={badgeDisplay(unreadFollowRequests, 40)} to='/follow_requests' />);
      }

      navItems.push(<ColumnLink key='getting_started' icon='ellipsis-h' text={intl.formatMessage(messages.misc)} to='/getting-started-misc' />);

      listItems = listItems.concat([
        <div key='9'>
          <ColumnLink key='lists' icon='bars' text={intl.formatMessage(messages.lists)} to='/lists' />
          {lists.filter(list => !columns.find(item => item.get('id') === 'LIST' && item.getIn(['params', 'id']) === list.get('id'))).map(list =>
            <ColumnLink key={`list-${list.get('id')}`} to={`/lists/${list.get('id')}`} icon='list-ul' text={list.get('title')} />,
          )}
        </div>,
      ]);
    }

    return (
      <Column bindToDocument={!multiColumn} name='getting-started' icon='asterisk' heading={intl.formatMessage(messages.heading)} label={intl.formatMessage(messages.menu)} hideHeadingOnMobile>
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
                { preferencesLink !== undefined && <ColumnLink icon='cog' text={intl.formatMessage(messages.preferences)} href={preferencesLink} /> }
                <ColumnLink icon='cogs' text={intl.formatMessage(messages.settings)} onClick={openSettings} />
              </>
            )}
          </div>

          <LinkFooter />
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

export default connect(makeMapStateToProps, mapDispatchToProps)(injectIntl(GettingStarted));

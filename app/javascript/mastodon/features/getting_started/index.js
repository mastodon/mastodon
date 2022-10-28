import React from 'react';
import Column from 'mastodon/components/column';
import ColumnHeader from 'mastodon/components/column_header';
import ColumnLink from '../ui/components/column_link';
import ColumnSubheading from '../ui/components/column_subheading';
import { defineMessages, injectIntl } from 'react-intl';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { me, showTrends } from '../../initial_state';
import { fetchFollowRequests } from 'mastodon/actions/accounts';
import { List as ImmutableList } from 'immutable';
import NavigationContainer from '../compose/containers/navigation_container';
import LinkFooter from 'mastodon/features/ui/components/link_footer';
import TrendsContainer from './containers/trends_container';
import { Helmet } from 'react-helmet';

const messages = defineMessages({
  home_timeline: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: { id: 'tabs_bar.notifications', defaultMessage: 'Notifications' },
  public_timeline: { id: 'navigation_bar.public_timeline', defaultMessage: 'Federated timeline' },
  settings_subheading: { id: 'column_subheading.settings', defaultMessage: 'Settings' },
  community_timeline: { id: 'navigation_bar.community_timeline', defaultMessage: 'Local timeline' },
  explore: { id: 'navigation_bar.explore', defaultMessage: 'Explore' },
  direct: { id: 'navigation_bar.direct', defaultMessage: 'Direct messages' },
  bookmarks: { id: 'navigation_bar.bookmarks', defaultMessage: 'Bookmarks' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  follow_requests: { id: 'navigation_bar.follow_requests', defaultMessage: 'Follow requests' },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favourites' },
  blocks: { id: 'navigation_bar.blocks', defaultMessage: 'Blocked users' },
  domain_blocks: { id: 'navigation_bar.domain_blocks', defaultMessage: 'Hidden domains' },
  mutes: { id: 'navigation_bar.mutes', defaultMessage: 'Muted users' },
  pins: { id: 'navigation_bar.pins', defaultMessage: 'Pinned posts' },
  lists: { id: 'navigation_bar.lists', defaultMessage: 'Lists' },
  discover: { id: 'navigation_bar.discover', defaultMessage: 'Discover' },
  personal: { id: 'navigation_bar.personal', defaultMessage: 'Personal' },
  security: { id: 'navigation_bar.security', defaultMessage: 'Security' },
  menu: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
});

const mapStateToProps = state => ({
  myAccount: state.getIn(['accounts', me]),
  unreadFollowRequests: state.getIn(['user_lists', 'follow_requests', 'items'], ImmutableList()).size,
});

const mapDispatchToProps = dispatch => ({
  fetchFollowRequests: () => dispatch(fetchFollowRequests()),
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

export default @connect(mapStateToProps, mapDispatchToProps)
@injectIntl
class GettingStarted extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object.isRequired,
    identity: PropTypes.object,
  };

  static propTypes = {
    intl: PropTypes.object.isRequired,
    myAccount: ImmutablePropTypes.map,
    multiColumn: PropTypes.bool,
    fetchFollowRequests: PropTypes.func.isRequired,
    unreadFollowRequests: PropTypes.number,
    unreadNotifications: PropTypes.number,
  };

  componentDidMount () {
    const { fetchFollowRequests } = this.props;
    const { signedIn } = this.context.identity;

    if (!signedIn) {
      return;
    }

    fetchFollowRequests();
  }

  render () {
    const { intl, myAccount, multiColumn, unreadFollowRequests } = this.props;
    const { signedIn } = this.context.identity;

    const navItems = [];

    navItems.push(
      <ColumnSubheading key='header-discover' text={intl.formatMessage(messages.discover)} />,
    );

    if (showTrends) {
      navItems.push(
        <ColumnLink key='explore' icon='hashtag' text={intl.formatMessage(messages.explore)} to='/explore' />,
      );
    }

    navItems.push(
      <ColumnLink key='community_timeline' icon='users' text={intl.formatMessage(messages.community_timeline)} to='/public/local' />,
      <ColumnLink key='public_timeline' icon='globe' text={intl.formatMessage(messages.public_timeline)} to='/public' />,
    );

    if (signedIn) {
      navItems.push(
        <ColumnSubheading key='header-personal' text={intl.formatMessage(messages.personal)} />,
        <ColumnLink key='home' icon='home' text={intl.formatMessage(messages.home_timeline)} to='/home' />,
        <ColumnLink key='direct' icon='at' text={intl.formatMessage(messages.direct)} to='/conversations' />,
        <ColumnLink key='bookmark' icon='bookmark' text={intl.formatMessage(messages.bookmarks)} to='/bookmarks' />,
        <ColumnLink key='favourites' icon='star' text={intl.formatMessage(messages.favourites)} to='/favourites' />,
        <ColumnLink key='lists' icon='list-ul' text={intl.formatMessage(messages.lists)} to='/lists' />,
      );

      if (myAccount.get('locked') || unreadFollowRequests > 0) {
        navItems.push(<ColumnLink key='follow_requests' icon='user-plus' text={intl.formatMessage(messages.follow_requests)} badge={badgeDisplay(unreadFollowRequests, 40)} to='/follow_requests' />);
      }

      navItems.push(
        <ColumnSubheading key='header-settings' text={intl.formatMessage(messages.settings_subheading)} />,
        <ColumnLink key='preferences' icon='gears' text={intl.formatMessage(messages.preferences)} href='/settings/preferences' />,
      );
    }

    return (
      <Column>
        {(signedIn && !multiColumn) ? <NavigationContainer /> : <ColumnHeader title={intl.formatMessage(messages.menu)} icon='bars' multiColumn={multiColumn} />}

        <div className='getting-started scrollable scrollable--flex'>
          <div className='getting-started__wrapper'>
            {navItems}
          </div>

          {!multiColumn && <div className='flex-spacer' />}

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

import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import { connect } from 'react-redux';
import Avatar from 'mastodon/components/avatar';
import Permalink from 'mastodon/components/permalink';
import { timelinePreview, showTrends, me } from 'mastodon/initial_state';
import ColumnLink from './column_link';
import DisabledAccountBanner from './disabled_account_banner';
import FollowRequestsColumnLink from './follow_requests_column_link';
import ListPanel from './list_panel';
import NotificationsCounterIcon from './notifications_counter_icon';
import SignInBanner from './sign_in_banner';
import NavigationPortal from 'mastodon/components/navigation_portal';
import { navRetracted } from 'mastodon/settings';

const messages = defineMessages({
  home: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: { id: 'tabs_bar.notifications', defaultMessage: 'Notifications' },
  explore: { id: 'explore.title', defaultMessage: 'Explore' },
  local: { id: 'tabs_bar.local_timeline', defaultMessage: 'Local' },
  federated: { id: 'tabs_bar.federated_timeline', defaultMessage: 'Federated' },
  menu: { id: 'navigation_bar.menu', defaultMessage: 'Menu' },
  direct: { id: 'navigation_bar.direct', defaultMessage: 'Direct messages' },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favourites' },
  bookmarks: { id: 'navigation_bar.bookmarks', defaultMessage: 'Bookmarks' },
  lists: { id: 'navigation_bar.lists', defaultMessage: 'Lists' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  followsAndFollowers: { id: 'navigation_bar.follows_and_followers', defaultMessage: 'Follows and followers' },
  about: { id: 'navigation_bar.about', defaultMessage: 'About' },
  search: { id: 'navigation_bar.search', defaultMessage: 'Search' },
  publish: { id: 'compose_form.publish', defaultMessage: 'Post' },
});

const Account = connect(state => ({
  account: state.getIn(['accounts', me]),
}))(({ account }) => (
  <Permalink className='column-link column-link--transparent navigation-panel--profile' href={account.get('url')} to={`/@${account.get('acct')}`} title={account.get('acct')}>
    <Avatar account={account} size={32} inline />
    <span>Profile</span>
  </Permalink>
));

export default @injectIntl
class NavigationPanel extends React.Component {

  constructor() {
    super();
    this.handleMenuToggle = this.handleMenuToggle.bind(this);
  }

  static contextTypes = {
    router: PropTypes.object.isRequired,
    identity: PropTypes.object.isRequired,
  };

  static propTypes = {
    intl: PropTypes.object.isRequired,
  };

  state = {
    retracted: navRetracted.get('hometown'),
  };

  componentDidMount() {
    const mainContent = document.querySelector('.columns-area--mobile');
    if (this.state.retracted) {
      mainContent.classList.add('fullWidth');
    }
  }

  handleMenuToggle() {
    this.setState({
      retracted: !this.state.retracted,
    }, () => navRetracted.set('hometown', this.state.retracted));
    const mainContent = document.querySelector('.columns-area--mobile');
    if (!this.state.retracted) {
      mainContent.classList.add('navigation-panel--retracted');
      mainContent.classList.remove('navigation-panel--extended');
    } else {
      mainContent.classList.add('navigation-panel--extended');
      mainContent.classList.remove('navigation-panel--retracted');
    }
  };

  render () {
    const { intl } = this.props;
    const { signedIn, disabledAccountId } = this.context.identity;

    const isWideSingleColumnLayout = document.querySelector('.columns-area__panels__pane--compositional') && window.getComputedStyle(document.querySelector('.columns-area__panels__pane--compositional')).display !== 'none';

    return (
      <div className='navigation-panel'>
        <ColumnLink transparent button onClick={this.handleMenuToggle} icon='bars' text={intl.formatMessage(messages.menu)} />

        { (isWideSingleColumnLayout || !this.state.retracted) && <div id='navigation-retractable'>
          {signedIn && (
            <React.Fragment>
              <Account />
              <ColumnLink id='navigation-panel__publish' transparent to='/publish' icon='pencil' text={intl.formatMessage(messages.publish)} />
              <ColumnLink transparent to='/home' icon='home' text={intl.formatMessage(messages.home)} />
              <ColumnLink transparent to='/notifications' icon={<NotificationsCounterIcon className='column-link__icon' />} text={intl.formatMessage(messages.notifications)} />
              <FollowRequestsColumnLink />
            </React.Fragment>
          )}

          {showTrends ? (
            <ColumnLink transparent to='/explore' icon='search' text={intl.formatMessage(messages.explore)} />
          ) : (
            <ColumnLink transparent to='/search' icon='search' text={intl.formatMessage(messages.search)} />
          )}

          {(signedIn || timelinePreview) && (
            <>
              <ColumnLink transparent to='/public/local' icon='users' text={intl.formatMessage(messages.local)} />
              <ColumnLink transparent exact to='/public' icon='globe' text={intl.formatMessage(messages.federated)} />
            </>
          )}

          {!signedIn && (
            <div className='navigation-panel__sign-in-banner'>
              <hr />
              { disabledAccountId ? <DisabledAccountBanner /> : <SignInBanner /> }
            </div>
          )}

          {signedIn && (
            <React.Fragment>
              <ColumnLink transparent to='/conversations' icon='at' text={intl.formatMessage(messages.direct)} />
              <ColumnLink transparent to='/favourites' icon='star' text={intl.formatMessage(messages.favourites)} />
              <ColumnLink transparent to='/bookmarks' icon='bookmark' text={intl.formatMessage(messages.bookmarks)} />
              <ColumnLink transparent to='/lists' icon='list-ul' text={intl.formatMessage(messages.lists)} />

              <ListPanel />

              <hr />

              <ColumnLink transparent href='/settings/preferences' icon='cog' text={intl.formatMessage(messages.preferences)} />
            </React.Fragment>
          )}

          <div className='navigation-panel__legal'>
            <hr />
            <ColumnLink transparent href='/about' icon='ellipsis-h' text={intl.formatMessage(messages.about)} />
          </div>
        </div>
        }

        <NavigationPortal />
      </div>
    );
  }

}

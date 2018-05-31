import React from 'react';
import Column from '../ui/components/column';
import ColumnLink from '../ui/components/column_link';
import ColumnSubheading from '../ui/components/column_subheading';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { me } from '../../initial_state';
import { fetchFollowRequests } from '../../actions/accounts';
import { List as ImmutableList } from 'immutable';
import { Link } from 'react-router-dom';
import { fetchTrends } from '../../actions/trends';
import Hashtag from '../../components/hashtag';
import NavigationBar from '../compose/components/navigation_bar';

const messages = defineMessages({
  home_timeline: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: { id: 'tabs_bar.notifications', defaultMessage: 'Notifications' },
  public_timeline: { id: 'navigation_bar.public_timeline', defaultMessage: 'Federated timeline' },
  settings_subheading: { id: 'column_subheading.settings', defaultMessage: 'Settings' },
  community_timeline: { id: 'navigation_bar.community_timeline', defaultMessage: 'Local timeline' },
  direct: { id: 'navigation_bar.direct', defaultMessage: 'Direct messages' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  follow_requests: { id: 'navigation_bar.follow_requests', defaultMessage: 'Follow requests' },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favourites' },
  blocks: { id: 'navigation_bar.blocks', defaultMessage: 'Blocked users' },
  domain_blocks: { id: 'navigation_bar.domain_blocks', defaultMessage: 'Hidden domains' },
  mutes: { id: 'navigation_bar.mutes', defaultMessage: 'Muted users' },
  pins: { id: 'navigation_bar.pins', defaultMessage: 'Pinned toots' },
  lists: { id: 'navigation_bar.lists', defaultMessage: 'Lists' },
  refresh_trends: { id: 'trends.refresh', defaultMessage: 'Refresh' },
  discover: { id: 'navigation_bar.discover', defaultMessage: 'Discover' },
  personal: { id: 'navigation_bar.personal', defaultMessage: 'Personal' },
  security: { id: 'navigation_bar.security', defaultMessage: 'Security' },
});

const mapStateToProps = state => ({
  myAccount: state.getIn(['accounts', me]),
  unreadFollowRequests: state.getIn(['user_lists', 'follow_requests', 'items'], ImmutableList()).size,
  trends: state.get('trends'),
});

const mapDispatchToProps = dispatch => ({
  fetchFollowRequests: () => dispatch(fetchFollowRequests()),
  fetchTrends: () => dispatch(fetchTrends()),
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

@connect(mapStateToProps, mapDispatchToProps)
@injectIntl
export default class GettingStarted extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    myAccount: ImmutablePropTypes.map.isRequired,
    columns: ImmutablePropTypes.list,
    multiColumn: PropTypes.bool,
    fetchFollowRequests: PropTypes.func.isRequired,
    unreadFollowRequests: PropTypes.number,
    unreadNotifications: PropTypes.number,
    trends: ImmutablePropTypes.list,
  };

  componentDidMount () {
    const { myAccount, fetchFollowRequests } = this.props;

    if (myAccount.get('locked')) {
      fetchFollowRequests();
    }

    setTimeout(() => this.props.fetchTrends(), 5000);
  }

  render () {
    const { intl, myAccount, multiColumn, unreadFollowRequests, trends } = this.props;

    const navItems = [];

    if (multiColumn) {
      navItems.push(
        <ColumnSubheading key='1' text={intl.formatMessage(messages.discover)} />,
        <ColumnLink key='2' icon='users' text={intl.formatMessage(messages.community_timeline)} to='/timelines/public/local' />,
        <ColumnLink key='3' icon='globe' text={intl.formatMessage(messages.public_timeline)} to='/timelines/public' />,
        <ColumnSubheading key='8' text={intl.formatMessage(messages.personal)} />
      );
    }

    navItems.push(
      <ColumnLink key='4' icon='envelope' text={intl.formatMessage(messages.direct)} to='/timelines/direct' />,
      <ColumnLink key='5' icon='star' text={intl.formatMessage(messages.favourites)} to='/favourites' />,
      <ColumnLink key='6' icon='bars' text={intl.formatMessage(messages.lists)} to='/lists' />
    );

    if (myAccount.get('locked')) {
      navItems.push(<ColumnLink key='7' icon='users' text={intl.formatMessage(messages.follow_requests)} badge={badgeDisplay(unreadFollowRequests, 40)} to='/follow_requests' />);
    }

    if (!multiColumn) {
      navItems.push(
        <ColumnSubheading key='9' text={intl.formatMessage(messages.settings_subheading)} />,
        <ColumnLink key='6' icon='gears' text={intl.formatMessage(messages.preferences)} href='/settings/preferences' />,
        <ColumnLink key='6' icon='lock' text={intl.formatMessage(messages.security)} href='/auth/edit' />
      );
    }

    return (
      <Column>
        {multiColumn && <div className='column-header__wrapper'>
          <h1 className='column-header'>
            <button>
              <i className='fa fa-bars fa-fw column-header__icon' />
              <FormattedMessage id='getting_started.heading' defaultMessage='Getting started' />
            </button>
          </h1>
        </div>}

        <div className='getting-started__wrapper'>
          {!multiColumn && <NavigationBar account={myAccount} />}
          {navItems}
        </div>

        {multiColumn && trends && <div className='getting-started__trends'>
          <div className='column-header__wrapper'>
            <h1 className='column-header'>
              <button>
                <i className='fa fa-fire fa-fw' />
                <FormattedMessage id='trends.header' defaultMessage='Trending now' />
              </button>
              <div className='column-header__buttons'>
                <button className='column-header__button' title={intl.formatMessage(messages.refresh_trends)} aria-label={intl.formatMessage(messages.refresh_trends)}><i className='fa fa-refresh' /></button>
              </div>
            </h1>
          </div>

          <div className='getting-started__scrollable'>{trends.take(3).map(hashtag => <Hashtag key={hashtag.get('name')} hashtag={hashtag} />)}</div>
        </div>}

        {!multiColumn && <div className='flex-spacer' />}

        <div className='getting-started getting-started__footer'>
          <ul>
            {multiColumn && <li><Link to='/keyboard-shortcuts'><FormattedMessage id='navigation_bar.keyboard_shortcuts' defaultMessage='Hotkeys' /></Link> · </li>}
            <li><a href='/about/more' target='_blank'><FormattedMessage id='navigation_bar.info' defaultMessage='About this instance' /></a> · </li>
            <li><a href='/terms' target='_blank'><FormattedMessage id='getting_started.terms' defaultMessage='Terms of service' /></a> · </li>
            <li><a href='https://github.com/tootsuite/documentation#documentation' target='_blank'><FormattedMessage id='getting_started.documentation' defaultMessage='Documentation' /></a> · </li>
            <li><a href='/auth/sign_out' data-method='delete'><FormattedMessage id='navigation_bar.logout' defaultMessage='Logout' /></a></li>
          </ul>

          <p>
            <FormattedMessage
              id='getting_started.open_source_notice'
              defaultMessage='Mastodon is open source software. You can contribute or report issues on GitHub at {github}.'
              values={{ github: <a href='https://github.com/tootsuite/mastodon' rel='noopener' target='_blank'>tootsuite/mastodon</a> }}
            />
          </p>
        </div>
      </Column>
    );
  }

}

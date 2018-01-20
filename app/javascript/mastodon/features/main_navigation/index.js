import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { defineMessages, injectIntl } from 'react-intl';
import ColumnLink from '../ui/components/column_link';
import ColumnSubheading from '../ui/components/column_subheading';

const messages = defineMessages({
  home_timeline: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: { id: 'tabs_bar.notifications', defaultMessage: 'Notifications' },
  public_timeline: { id: 'navigation_bar.public_timeline', defaultMessage: 'Federated timeline' },
  navigation_subheading: { id: 'column_subheading.navigation', defaultMessage: 'Navigation' },
  community_timeline: { id: 'navigation_bar.community_timeline', defaultMessage: 'Local timeline' },
  follow_requests: { id: 'navigation_bar.follow_requests', defaultMessage: 'Follow requests' },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favourites' },
  info: { id: 'navigation_bar.info', defaultMessage: 'Extended information' },
  lists: { id: 'navigation_bar.lists', defaultMessage: 'Lists' },
  keyboard_shortcuts: { id: 'navigation_bar.keyboard_shortcuts', defaultMessage: 'Keyboard shortcuts' },
});

@injectIntl
export default class Navigation extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    followRequestsHidden: PropTypes.bool,
    hiddenColumns: ImmutablePropTypes.list,
    multiColumn: PropTypes.bool,
  };

  render () {
    const { intl, followRequestsHidden, hiddenColumns, multiColumn } = this.props;
    const navItems = [];

    if (multiColumn) {
      if (!hiddenColumns.find(item => item.get('id') === 'HOME')) {
        navItems.push(<ColumnLink key='1' icon='home' text={intl.formatMessage(messages.home_timeline)} to='/timelines/home' />);
      }

      if (!hiddenColumns.find(item => item.get('id') === 'NOTIFICATIONS')) {
        navItems.push(<ColumnLink key='2' icon='bell' text={intl.formatMessage(messages.notifications)} to='/notifications' />);
      }

      if (!hiddenColumns.find(item => item.get('id') === 'COMMUNITY')) {
        navItems.push(<ColumnLink key='3' icon='users' text={intl.formatMessage(messages.community_timeline)} to='/timelines/public/local' />);
      }

      if (!hiddenColumns.find(item => item.get('id') === 'PUBLIC')) {
        navItems.push(<ColumnLink key='4' icon='globe' text={intl.formatMessage(messages.public_timeline)} to='/timelines/public' />);
      }
    }

    navItems.push(
      <ColumnLink key='5' icon='star' text={intl.formatMessage(messages.favourites)} to='/favourites' />,
      <ColumnLink key='6' icon='bars' text={intl.formatMessage(messages.lists)} to='/lists' />
    );

    if (followRequestsHidden) {
      navItems.push(<ColumnLink key='7' icon='users' text={intl.formatMessage(messages.follow_requests)} to='/follow_requests' />);
    }

    if (multiColumn) {
      navItems.push(<ColumnLink key='8' icon='question' text={intl.formatMessage(messages.keyboard_shortcuts)} to='/keyboard-shortcuts' />);
    }

    navItems.push(<ColumnLink key='9' icon='book' text={intl.formatMessage(messages.info)} href='/about/more' />);

    return (
      <div className='navigation__wrapper'>
        <ColumnSubheading text={intl.formatMessage(messages.navigation_subheading)} />
        {navItems}
      </div>
    );
  }

}

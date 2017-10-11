import React from 'react';
import Column from '../ui/components/column';
import ColumnLink from '../ui/components/column_link';
import ColumnSubheading from '../ui/components/column_subheading';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  heading: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
  home_timeline: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: { id: 'tabs_bar.notifications', defaultMessage: 'Notifications' },
  public_timeline: { id: 'navigation_bar.public_timeline', defaultMessage: 'Federated timeline' },
  navigation_subheading: { id: 'column_subheading.navigation', defaultMessage: 'Navigation' },
  settings_subheading: { id: 'column_subheading.settings', defaultMessage: 'Settings' },
  community_timeline: { id: 'navigation_bar.community_timeline', defaultMessage: 'Local timeline' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  follow_requests: { id: 'navigation_bar.follow_requests', defaultMessage: 'Follow requests' },
  sign_out: { id: 'navigation_bar.logout', defaultMessage: 'Logout' },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favourites' },
  blocks: { id: 'navigation_bar.blocks', defaultMessage: 'Blocked users' },
  mutes: { id: 'navigation_bar.mutes', defaultMessage: 'Muted users' },
  info: { id: 'navigation_bar.info', defaultMessage: 'Extended information' },
  pins: { id: 'navigation_bar.pins', defaultMessage: 'Pinned toots' },
});

const mapStateToProps = state => ({
  me: state.getIn(['accounts', state.getIn(['meta', 'me'])]),
  columns: state.getIn(['settings', 'columns']),
});

@connect(mapStateToProps)
@injectIntl
export default class GettingStarted extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    me: ImmutablePropTypes.map.isRequired,
    columns: ImmutablePropTypes.list,
    multiColumn: PropTypes.bool,
  };

  render () {
    const { intl, me, columns, multiColumn } = this.props;

    let navItems = [];

    if (multiColumn) {
      if (!columns.find(item => item.get('id') === 'HOME')) {
        navItems.push(<ColumnLink key='0' icon='home' text={intl.formatMessage(messages.home_timeline)} to='/timelines/home' />);
      }

      if (!columns.find(item => item.get('id') === 'NOTIFICATIONS')) {
        navItems.push(<ColumnLink key='1' icon='bell' text={intl.formatMessage(messages.notifications)} to='/notifications' />);
      }

      if (!columns.find(item => item.get('id') === 'COMMUNITY')) {
        navItems.push(<ColumnLink key='2' icon='users' text={intl.formatMessage(messages.community_timeline)} to='/timelines/public/local' />);
      }

      if (!columns.find(item => item.get('id') === 'PUBLIC')) {
        navItems.push(<ColumnLink key='3' icon='globe' text={intl.formatMessage(messages.public_timeline)} to='/timelines/public' />);
      }
    }

    navItems = navItems.concat([
      <ColumnLink key='4' icon='star' text={intl.formatMessage(messages.favourites)} to='/favourites' />,
      <ColumnLink key='5' icon='thumb-tack' text={intl.formatMessage(messages.pins)} to='/pinned' />,
    ]);

    if (me.get('locked')) {
      navItems.push(<ColumnLink key='6' icon='users' text={intl.formatMessage(messages.follow_requests)} to='/follow_requests' />);
    }

    navItems = navItems.concat([
      <ColumnLink key='7' icon='volume-off' text={intl.formatMessage(messages.mutes)} to='/mutes' />,
      <ColumnLink key='8' icon='ban' text={intl.formatMessage(messages.blocks)} to='/blocks' />,
    ]);

    return (
      <Column icon='asterisk' heading={intl.formatMessage(messages.heading)} hideHeadingOnMobile>
        <div className='getting-started__wrapper'>
          <ColumnSubheading text={intl.formatMessage(messages.navigation_subheading)} />
          {navItems}
          <ColumnSubheading text={intl.formatMessage(messages.settings_subheading)} />
          <ColumnLink icon='book' text={intl.formatMessage(messages.info)} href='/about/more' />
          <ColumnLink icon='cog' text={intl.formatMessage(messages.preferences)} href='/settings/preferences' />
          <ColumnLink icon='sign-out' text={intl.formatMessage(messages.sign_out)} href='/auth/sign_out' method='delete' />
        </div>

        <div className='getting-started__footer scrollable optionally-scrollable'>
          <div className='static-content getting-started'>
            <p>
              <a href='https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/FAQ.md' rel='noopener' target='_blank'><FormattedMessage id='getting_started.faq' defaultMessage='FAQ' /></a> • <a href='https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/User-guide.md' rel='noopener' target='_blank'><FormattedMessage id='getting_started.userguide' defaultMessage='User Guide' /></a> • <a href='https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/Apps.md' rel='noopener' target='_blank'><FormattedMessage id='getting_started.appsshort' defaultMessage='Apps' /></a>
            </p>
            <p>
              <FormattedMessage
                id='getting_started.open_source_notice'
                defaultMessage='Mastodon is open source software. You can contribute or report issues on GitHub at {github}.'
                values={{ github: <a href='https://github.com/tootsuite/mastodon' rel='noopener' target='_blank'>tootsuite/mastodon</a> }}
              />
            </p>
          </div>
        </div>
      </Column>
    );
  }

}

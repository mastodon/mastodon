import React from 'react';
import Column from '../ui/components/column';
import ColumnLink from '../ui/components/column_link';
import ColumnSubheading from '../ui/components/column_subheading';
import { Link } from 'react-router';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  heading: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
  public_timeline: { id: 'navigation_bar.public_timeline', defaultMessage: 'Federated timeline' },
  navigation_subheading: { id: 'column_subheading.navigation', defaultMessage: 'Navigation'},
  settings_subheading: { id: 'column_subheading.settings', defaultMessage: 'Settings'},
  community_timeline: { id: 'navigation_bar.community_timeline', defaultMessage: 'Local timeline' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  follow_requests: { id: 'navigation_bar.follow_requests', defaultMessage: 'Follow requests' },
  sign_out: { id: 'navigation_bar.logout', defaultMessage: 'Logout' },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favourites' },
  blocks: { id: 'navigation_bar.blocks', defaultMessage: 'Blocked users' },
  mutes: { id: 'navigation_bar.mutes', defaultMessage: 'Muted users' },
  info: { id: 'navigation_bar.info', defaultMessage: 'Extended information' }
});

const mapStateToProps = state => ({
  me: state.getIn(['accounts', state.getIn(['meta', 'me'])])
});

class GettingStarted extends ImmutablePureComponent {

  render () {
    const { intl, me } = this.props;

    let followRequests = '';

    if (me.get('locked')) {
      followRequests = <ColumnLink icon='users' text={intl.formatMessage(messages.follow_requests)} to='/follow_requests' />;
    }

    return (
      <Column icon='asterisk' heading={intl.formatMessage(messages.heading)} hideHeadingOnMobile={true}>
        <div className='getting-started__wrapper'>
          <ColumnSubheading text={intl.formatMessage(messages.navigation_subheading)}/>
          <ColumnLink icon='users' hideOnMobile={true} text={intl.formatMessage(messages.community_timeline)} to='/timelines/public/local' />
          <ColumnLink icon='globe' hideOnMobile={true} text={intl.formatMessage(messages.public_timeline)} to='/timelines/public' />
          <ColumnLink icon='star' text={intl.formatMessage(messages.favourites)} to='/favourites' />
          {followRequests}
          <ColumnLink icon='volume-off' text={intl.formatMessage(messages.mutes)} to='/mutes' />
          <ColumnLink icon='ban' text={intl.formatMessage(messages.blocks)} to='/blocks' />
          <ColumnSubheading text={intl.formatMessage(messages.settings_subheading)}/>
          <ColumnLink icon='book' text={intl.formatMessage(messages.info)} href='/about/more' />
          <ColumnLink icon='cog' text={intl.formatMessage(messages.preferences)} href='/settings/preferences' />
          <ColumnLink icon='sign-out' text={intl.formatMessage(messages.sign_out)} href='/auth/sign_out' method='delete' />
        </div>

        <div className='scrollable optionally-scrollable' style={{ display: 'flex', flexDirection: 'column' }}>
          <div className='static-content getting-started'>
            <p><FormattedMessage id='getting_started.support' defaultMessage='{faq} • {userguide} • {apps}' values={{ faq: <a href="https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/FAQ.md" target="_blank"><FormattedMessage id='getting_started.faq' defaultMessage='FAQ' /></a>, userguide: <a href="https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/User-guide.md" target="_blank"><FormattedMessage id='getting_started.userguide' defaultMessage='User Guide' /></a>, apps: <a href="https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/Apps.md" target="_blank"><FormattedMessage id='getting_started.appsshort' defaultMessage='Apps' /></a> }} /></p>
            <p><FormattedMessage id='getting_started.open_source_notice' defaultMessage='Mastodon is open source software. You can contribute or report issues on GitHub at {github}.' values={{ github: <a href="https://github.com/tootsuite/mastodon" target="_blank">tootsuite/mastodon</a> }} /></p>
          </div>
        </div>
      </Column>
    );
  }
}

GettingStarted.propTypes = {
  intl: PropTypes.object.isRequired,
  me: ImmutablePropTypes.map.isRequired
};

export default connect(mapStateToProps)(injectIntl(GettingStarted));

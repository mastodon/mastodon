import React from 'react';
import Column from 'flavours/glitch/features/ui/components/column';
import ColumnLink from 'flavours/glitch/features/ui/components/column_link';
import ColumnSubheading from 'flavours/glitch/features/ui/components/column_subheading';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import { openModal } from 'flavours/glitch/actions/modal';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { me } from 'flavours/glitch/util/initial_state';

const messages = defineMessages({
  heading: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
  home_timeline: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: { id: 'tabs_bar.notifications', defaultMessage: 'Notifications' },
  public_timeline: { id: 'navigation_bar.public_timeline', defaultMessage: 'Federated timeline' },
  navigation_subheading: { id: 'column_subheading.navigation', defaultMessage: 'Navigation' },
  settings_subheading: { id: 'column_subheading.settings', defaultMessage: 'Settings' },
  community_timeline: { id: 'navigation_bar.community_timeline', defaultMessage: 'Local timeline' },
  direct: { id: 'navigation_bar.direct', defaultMessage: 'Direct messages' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  settings: { id: 'navigation_bar.app_settings', defaultMessage: 'App settings' },
  follow_requests: { id: 'navigation_bar.follow_requests', defaultMessage: 'Follow requests' },
  sign_out: { id: 'navigation_bar.logout', defaultMessage: 'Logout' },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favourites' },
  blocks: { id: 'navigation_bar.blocks', defaultMessage: 'Blocked users' },
  mutes: { id: 'navigation_bar.mutes', defaultMessage: 'Muted users' },
  info: { id: 'navigation_bar.info', defaultMessage: 'Extended information' },
  show_me_around: { id: 'getting_started.onboarding', defaultMessage: 'Show me around' },
  pins: { id: 'navigation_bar.pins', defaultMessage: 'Pinned toots' },
  lists: { id: 'navigation_bar.lists', defaultMessage: 'Lists' },
  keyboard_shortcuts: { id: 'navigation_bar.keyboard_shortcuts', defaultMessage: 'Keyboard shortcuts' },
});

const mapStateToProps = state => ({
  myAccount: state.getIn(['accounts', me]),
  columns: state.getIn(['settings', 'columns']),
});

@connect(mapStateToProps)
@injectIntl
export default class GettingStarted extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    myAccount: ImmutablePropTypes.map.isRequired,
    columns: ImmutablePropTypes.list,
    multiColumn: PropTypes.bool,
    dispatch: PropTypes.func.isRequired,
  };

  openSettings = () => {
    this.props.dispatch(openModal('SETTINGS', {}));
  }

  openOnboardingModal = (e) => {
    e.preventDefault();
    this.props.dispatch(openModal('ONBOARDING'));
  }

  render () {
    const { intl, myAccount, columns, multiColumn } = this.props;

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

    if (!multiColumn || !columns.find(item => item.get('id') === 'DIRECT')) {
      navItems.push(<ColumnLink key='4' icon='envelope' text={intl.formatMessage(messages.direct)} to='/timelines/direct' />);
    }

    navItems = navItems.concat([
      <ColumnLink key='5' icon='star' text={intl.formatMessage(messages.favourites)} to='/favourites' />,
      <ColumnLink key='6' icon='thumb-tack' text={intl.formatMessage(messages.pins)} to='/pinned' />,
      <ColumnLink key='10' icon='bars' text={intl.formatMessage(messages.lists)} to='/lists' />,
    ]);

    if (myAccount.get('locked')) {
      navItems.push(<ColumnLink key='7' icon='users' text={intl.formatMessage(messages.follow_requests)} to='/follow_requests' />);
    }

    navItems = navItems.concat([
      <ColumnLink key='8' icon='volume-off' text={intl.formatMessage(messages.mutes)} to='/mutes' />,
      <ColumnLink key='9' icon='ban' text={intl.formatMessage(messages.blocks)} to='/blocks' />,
    ]);

    return (
      <Column name='getting-started' icon='asterisk' heading={intl.formatMessage(messages.heading)} hideHeadingOnMobile>
        <div className='scrollable optionally-scrollable'>
          <div className='getting-started__wrapper'>
            <ColumnSubheading text={intl.formatMessage(messages.navigation_subheading)} />
            {navItems}
            <ColumnSubheading text={intl.formatMessage(messages.settings_subheading)} />
            <ColumnLink icon='book' text={intl.formatMessage(messages.info)} href='/about/more' />
            <ColumnLink icon='hand-o-right' text={intl.formatMessage(messages.show_me_around)} onClick={this.openOnboardingModal} />
            <ColumnLink icon='cog' text={intl.formatMessage(messages.preferences)} href='/settings/preferences' />
            <ColumnLink icon='cogs' text={intl.formatMessage(messages.settings)} onClick={this.openSettings} />
            <ColumnLink icon='sign-out' text={intl.formatMessage(messages.sign_out)} href='/auth/sign_out' method='delete' />
          </div>

          <div className='getting-started__footer'>
            <div className='static-content getting-started'>
              <p>
                <a href='https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/FAQ.md' rel='noopener' target='_blank'>
                  <FormattedMessage id='getting_started.faq' defaultMessage='FAQ' />
                </a>&nbsp;•&nbsp;
                <a href='https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/User-guide.md' rel='noopener' target='_blank'>
                  <FormattedMessage id='getting_started.userguide' defaultMessage='User Guide' />
                </a>&nbsp;•&nbsp;
                <a href='https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/Apps.md' rel='noopener' target='_blank'>
                  <FormattedMessage id='getting_started.appsshort' defaultMessage='Apps' />
                </a>
              </p>
              <p>
                <FormattedMessage
                  id='getting_started.open_source_notice'
                  defaultMessage='Glitchsoc is open source software, a friendly fork of {Mastodon}. You can contribute or report issues on GitHub at {github}.'
                  values={{
                    github: <a href='https://github.com/glitch-soc/mastodon' rel='noopener' target='_blank'>glitch-soc/mastodon</a>,
                    Mastodon: <a href='https://github.com/tootsuite/mastodon' rel='noopener' target='_blank'>Mastodon</a>,
                  }}
                />
              </p>
            </div>
          </div>
        </div>
      </Column>
    );
  }

}

import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import DropdownMenuContainer from '../../../containers/dropdown_menu_container';
import { NavLink } from 'react-router-dom';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { me } from '../../../initial_state';
import { shortNumberFormat } from '../../../utils/numbers';

const messages = defineMessages({
  mention: { id: 'account.mention', defaultMessage: 'Mention @{name}' },
  direct: { id: 'account.direct', defaultMessage: 'Direct message @{name}' },
  edit_profile: { id: 'account.edit_profile', defaultMessage: 'Edit profile' },
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock @{name}' },
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  unmute: { id: 'account.unmute', defaultMessage: 'Unmute @{name}' },
  block: { id: 'account.block', defaultMessage: 'Block @{name}' },
  mute: { id: 'account.mute', defaultMessage: 'Mute @{name}' },
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  report: { id: 'account.report', defaultMessage: 'Report @{name}' },
  share: { id: 'account.share', defaultMessage: 'Share @{name}\'s profile' },
  media: { id: 'account.media', defaultMessage: 'Media' },
  blockDomain: { id: 'account.block_domain', defaultMessage: 'Hide everything from {domain}' },
  unblockDomain: { id: 'account.unblock_domain', defaultMessage: 'Unhide {domain}' },
  hideReblogs: { id: 'account.hide_reblogs', defaultMessage: 'Hide boosts from @{name}' },
  showReblogs: { id: 'account.show_reblogs', defaultMessage: 'Show boosts from @{name}' },
  pins: { id: 'navigation_bar.pins', defaultMessage: 'Pinned toots' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  follow_requests: { id: 'navigation_bar.follow_requests', defaultMessage: 'Follow requests' },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favourites' },
  lists: { id: 'navigation_bar.lists', defaultMessage: 'Lists' },
  blocks: { id: 'navigation_bar.blocks', defaultMessage: 'Blocked users' },
  domain_blocks: { id: 'navigation_bar.domain_blocks', defaultMessage: 'Hidden domains' },
  mutes: { id: 'navigation_bar.mutes', defaultMessage: 'Muted users' },
  endorse: { id: 'account.endorse', defaultMessage: 'Feature on profile' },
  unendorse: { id: 'account.unendorse', defaultMessage: 'Don\'t feature on profile' },
});

export default @injectIntl
class ActionBar extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    onFollow: PropTypes.func,
    onBlock: PropTypes.func.isRequired,
    onMention: PropTypes.func.isRequired,
    onDirect: PropTypes.func.isRequired,
    onReblogToggle: PropTypes.func.isRequired,
    onReport: PropTypes.func.isRequired,
    onMute: PropTypes.func.isRequired,
    onBlockDomain: PropTypes.func.isRequired,
    onUnblockDomain: PropTypes.func.isRequired,
    onEndorseToggle: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleShare = () => {
    navigator.share({
      url: this.props.account.get('url'),
    });
  }

  isStatusesPageActive = (match, location) => {
    if (!match) {
      return false;
    }
    return !location.pathname.match(/\/(followers|following)\/?$/);
  }

  render () {
    const { account, intl } = this.props;

    let menu = [];
    let extraInfo = '';

    if (account.get('id') !== me) {
      menu.push({ text: intl.formatMessage(messages.mention, { name: account.get('username') }), action: this.props.onMention });
      menu.push({ text: intl.formatMessage(messages.direct, { name: account.get('username') }), action: this.props.onDirect });
      menu.push(null);
    }

    if ('share' in navigator) {
      menu.push({ text: intl.formatMessage(messages.share, { name: account.get('username') }), action: this.handleShare });
      menu.push(null);
    }

    if (account.get('id') === me) {
      menu.push({ text: intl.formatMessage(messages.edit_profile), href: '/settings/profile' });
      menu.push({ text: intl.formatMessage(messages.preferences), href: '/settings/preferences' });
      menu.push({ text: intl.formatMessage(messages.pins), to: '/pinned' });
      menu.push(null);
      menu.push({ text: intl.formatMessage(messages.follow_requests), to: '/follow_requests' });
      menu.push({ text: intl.formatMessage(messages.favourites), to: '/favourites' });
      menu.push({ text: intl.formatMessage(messages.lists), to: '/lists' });
      menu.push(null);
      menu.push({ text: intl.formatMessage(messages.mutes), to: '/mutes' });
      menu.push({ text: intl.formatMessage(messages.blocks), to: '/blocks' });
      menu.push({ text: intl.formatMessage(messages.domain_blocks), to: '/domain_blocks' });
    } else {
      if (account.getIn(['relationship', 'following'])) {
        if (account.getIn(['relationship', 'showing_reblogs'])) {
          menu.push({ text: intl.formatMessage(messages.hideReblogs, { name: account.get('username') }), action: this.props.onReblogToggle });
        } else {
          menu.push({ text: intl.formatMessage(messages.showReblogs, { name: account.get('username') }), action: this.props.onReblogToggle });
        }

        menu.push({ text: intl.formatMessage(account.getIn(['relationship', 'endorsed']) ? messages.unendorse : messages.endorse), action: this.props.onEndorseToggle });
        menu.push(null);
      }

      if (account.getIn(['relationship', 'muting'])) {
        menu.push({ text: intl.formatMessage(messages.unmute, { name: account.get('username') }), action: this.props.onMute });
      } else {
        menu.push({ text: intl.formatMessage(messages.mute, { name: account.get('username') }), action: this.props.onMute });
      }

      if (account.getIn(['relationship', 'blocking'])) {
        menu.push({ text: intl.formatMessage(messages.unblock, { name: account.get('username') }), action: this.props.onBlock });
      } else {
        menu.push({ text: intl.formatMessage(messages.block, { name: account.get('username') }), action: this.props.onBlock });
      }

      menu.push({ text: intl.formatMessage(messages.report, { name: account.get('username') }), action: this.props.onReport });
    }

    if (account.get('acct') !== account.get('username')) {
      const domain = account.get('acct').split('@')[1];

      extraInfo = (
        <div className='account__disclaimer'>
          <FormattedMessage
            id='account.disclaimer_full'
            defaultMessage="Information below may reflect the user's profile incompletely."
          />
          {' '}
          <a target='_blank' rel='noopener' href={account.get('url')}>
            <FormattedMessage id='account.view_full_profile' defaultMessage='View full profile' />
          </a>
        </div>
      );

      menu.push(null);

      if (account.getIn(['relationship', 'domain_blocking'])) {
        menu.push({ text: intl.formatMessage(messages.unblockDomain, { domain }), action: this.props.onUnblockDomain });
      } else {
        menu.push({ text: intl.formatMessage(messages.blockDomain, { domain }), action: this.props.onBlockDomain });
      }
    }

    return (
      <div>
        {extraInfo}

        <div className='account__action-bar'>
          <div className='account__action-bar-links'>
            <NavLink isActive={this.isStatusesPageActive} activeClassName='active' className='account__action-bar__tab' to={`/accounts/${account.get('id')}`} title={intl.formatNumber(account.get('statuses_count'))}>
              <FormattedMessage id='account.posts' defaultMessage='Toots' />
              <strong>{shortNumberFormat(account.get('statuses_count'))}</strong>
            </NavLink>

            <NavLink exact activeClassName='active' className='account__action-bar__tab' to={`/accounts/${account.get('id')}/following`} title={intl.formatNumber(account.get('following_count'))}>
              <FormattedMessage id='account.follows' defaultMessage='Follows' />
              <strong>{shortNumberFormat(account.get('following_count'))}</strong>
            </NavLink>

            <NavLink exact activeClassName='active' className='account__action-bar__tab' to={`/accounts/${account.get('id')}/followers`} title={intl.formatNumber(account.get('followers_count'))}>
              <FormattedMessage id='account.followers' defaultMessage='Followers' />
              <strong>{shortNumberFormat(account.get('followers_count'))}</strong>
            </NavLink>
          </div>

          <div className='account__action-bar-dropdown'>
            <DropdownMenuContainer items={menu} icon='ellipsis-v' size={24} direction='right' />
          </div>
        </div>
      </div>
    );
  }

}

import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import DropdownMenuContainer from 'flavours/glitch/containers/dropdown_menu_container';
import { NavLink } from 'react-router-dom';
import { defineMessages, injectIntl, FormattedMessage, FormattedNumber } from 'react-intl';
import { me, isStaff } from 'flavours/glitch/util/initial_state';
import { profileLink, accountAdminLink } from 'flavours/glitch/util/backend_links';

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
  endorse: { id: 'account.endorse', defaultMessage: 'Feature on profile' },
  unendorse: { id: 'account.unendorse', defaultMessage: 'Don\'t feature on profile' },
  add_or_remove_from_list: { id: 'account.add_or_remove_from_list', defaultMessage: 'Add or Remove from lists' },
  admin_account: { id: 'status.admin_account', defaultMessage: 'Open moderation interface for @{name}' },
});

@injectIntl
export default class ActionBar extends React.PureComponent {

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
    onAddToList: PropTypes.func.isRequired,
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

    menu.push({ text: intl.formatMessage(messages.mention, { name: account.get('username') }), action: this.props.onMention });
    menu.push({ text: intl.formatMessage(messages.direct, { name: account.get('username') }), action: this.props.onDirect });

    if ('share' in navigator) {
      menu.push({ text: intl.formatMessage(messages.share, { name: account.get('username') }), action: this.handleShare });
    }

    menu.push(null);

    if (account.get('id') === me) {
      if (profileLink !== undefined) {
        menu.push({ text: intl.formatMessage(messages.edit_profile), href: profileLink });
      }
    } else {
      if (account.getIn(['relationship', 'following'])) {
        if (account.getIn(['relationship', 'showing_reblogs'])) {
          menu.push({ text: intl.formatMessage(messages.hideReblogs, { name: account.get('username') }), action: this.props.onReblogToggle });
        } else {
          menu.push({ text: intl.formatMessage(messages.showReblogs, { name: account.get('username') }), action: this.props.onReblogToggle });
        }

        menu.push({ text: intl.formatMessage(account.getIn(['relationship', 'endorsed']) ? messages.unendorse : messages.endorse), action: this.props.onEndorseToggle });
        menu.push({ text: intl.formatMessage(messages.add_or_remove_from_list), action: this.props.onAddToList });
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

    if (account.get('id') !== me && isStaff && (accountAdminLink !== undefined)) {
      menu.push(null);
      menu.push({
        text: intl.formatMessage(messages.admin_account, { name: account.get('username') }),
        href: accountAdminLink(account.get('id')),
      });
    }

    return (
      <div>
        {extraInfo}

        <div className='account__action-bar'>
          <div className='account__action-bar-dropdown'>
            <DropdownMenuContainer items={menu} icon='bars' size={24} direction='right' />
          </div>

          <div className='account__action-bar-links'>
            <NavLink isActive={this.isStatusesPageActive} activeClassName='active' className='account__action-bar__tab' to={`/accounts/${account.get('id')}`}>
              <FormattedMessage id='account.posts' defaultMessage='Posts' />
              <strong><FormattedNumber value={account.get('statuses_count')} /></strong>
            </NavLink>

            <NavLink exact activeClassName='active' className='account__action-bar__tab' to={`/accounts/${account.get('id')}/following`}>
              <FormattedMessage id='account.follows' defaultMessage='Follows' />
              <strong><FormattedNumber value={account.get('following_count')} /></strong>
            </NavLink>

            <NavLink exact activeClassName='active' className='account__action-bar__tab' to={`/accounts/${account.get('id')}/followers`}>
              <FormattedMessage id='account.followers' defaultMessage='Followers' />
              <strong>{ account.get('followers_count') < 0 ? '-' : <FormattedNumber value={account.get('followers_count')} /> }</strong>
            </NavLink>
          </div>
        </div>
      </div>
    );
  }

}

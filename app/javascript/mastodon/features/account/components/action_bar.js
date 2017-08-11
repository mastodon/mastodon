import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import DropdownMenuContainer from '../../../containers/dropdown_menu_container';
import Link from 'react-router-dom/Link';
import { defineMessages, injectIntl, FormattedMessage, FormattedNumber } from 'react-intl';

const messages = defineMessages({
  mention: { id: 'account.mention', defaultMessage: 'Mention @{name}' },
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
});

@injectIntl
export default class ActionBar extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    me: PropTypes.number.isRequired,
    onFollow: PropTypes.func,
    onBlock: PropTypes.func.isRequired,
    onMention: PropTypes.func.isRequired,
    onReport: PropTypes.func.isRequired,
    onMute: PropTypes.func.isRequired,
    onBlockDomain: PropTypes.func.isRequired,
    onUnblockDomain: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleShare = () => {
    navigator.share({
      url: this.props.account.get('url'),
    });
  }

  render () {
    const { account, me, intl } = this.props;

    let menu = [];
    let extraInfo = '';

    menu.push({ text: intl.formatMessage(messages.mention, { name: account.get('username') }), action: this.props.onMention });
    if ('share' in navigator) {
      menu.push({ text: intl.formatMessage(messages.share, { name: account.get('username') }), action: this.handleShare });
    }
    menu.push(null);
    menu.push({ text: intl.formatMessage(messages.media), to: `/accounts/${account.get('id')}/media` });
    menu.push(null);

    if (account.get('id') === me) {
      menu.push({ text: intl.formatMessage(messages.edit_profile), href: '/settings/profile' });
    } else {
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
          <div className='account__action-bar-dropdown'>
            <DropdownMenuContainer items={menu} icon='bars' size={24} direction='right' />
          </div>

          <div className='account__action-bar-links'>
            <Link className='account__action-bar__tab' to={`/accounts/${account.get('id')}`}>
              <span><FormattedMessage id='account.posts' defaultMessage='Posts' /></span>
              <strong><FormattedNumber value={account.get('statuses_count')} /></strong>
            </Link>

            <Link className='account__action-bar__tab' to={`/accounts/${account.get('id')}/following`}>
              <span><FormattedMessage id='account.follows' defaultMessage='Follows' /></span>
              <strong><FormattedNumber value={account.get('following_count')} /></strong>
            </Link>

            <Link className='account__action-bar__tab' to={`/accounts/${account.get('id')}/followers`}>
              <span><FormattedMessage id='account.followers' defaultMessage='Followers' /></span>
              <strong><FormattedNumber value={account.get('followers_count')} /></strong>
            </Link>
          </div>
        </div>
      </div>
    );
  }

}

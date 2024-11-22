import PropTypes from 'prop-types';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Helmet } from 'react-helmet';
import { NavLink, withRouter } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import CheckIcon from '@/material-icons/400-24px/check.svg?react';
import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import NotificationsIcon from '@/material-icons/400-24px/notifications.svg?react';
import NotificationsActiveIcon from '@/material-icons/400-24px/notifications_active-fill.svg?react';
import ShareIcon from '@/material-icons/400-24px/share.svg?react';
import { Avatar } from 'mastodon/components/avatar';
import { Badge, AutomatedBadge, GroupBadge } from 'mastodon/components/badge';
import { Button } from 'mastodon/components/button';
import { CopyIconButton } from 'mastodon/components/copy_icon_button';
import { FollowersCounter, FollowingCounter, StatusesCounter } from 'mastodon/components/counters';
import { Icon }  from 'mastodon/components/icon';
import { IconButton } from 'mastodon/components/icon_button';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { ShortNumber } from 'mastodon/components/short_number';
import DropdownMenuContainer from 'mastodon/containers/dropdown_menu_container';
import { identityContextPropShape, withIdentity } from 'mastodon/identity_context';
import { autoPlayGif, me, domain as localDomain } from 'mastodon/initial_state';
import { PERMISSION_MANAGE_USERS, PERMISSION_MANAGE_FEDERATION } from 'mastodon/permissions';
import { WithRouterPropTypes } from 'mastodon/utils/react_router';

import AccountNoteContainer from '../containers/account_note_container';
import FollowRequestNoteContainer from '../containers/follow_request_note_container';

import { DomainPill } from './domain_pill';

const messages = defineMessages({
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  followBack: { id: 'account.follow_back', defaultMessage: 'Follow back' },
  mutual: { id: 'account.mutual', defaultMessage: 'Mutual' },
  cancel_follow_request: { id: 'account.cancel_follow_request', defaultMessage: 'Withdraw follow request' },
  requested: { id: 'account.requested', defaultMessage: 'Awaiting approval. Click to cancel follow request' },
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock @{name}' },
  edit_profile: { id: 'account.edit_profile', defaultMessage: 'Edit profile' },
  linkVerifiedOn: { id: 'account.link_verified_on', defaultMessage: 'Ownership of this link was checked on {date}' },
  account_locked: { id: 'account.locked_info', defaultMessage: 'This account privacy status is set to locked. The owner manually reviews who can follow them.' },
  mention: { id: 'account.mention', defaultMessage: 'Mention @{name}' },
  direct: { id: 'account.direct', defaultMessage: 'Privately mention @{name}' },
  unmute: { id: 'account.unmute', defaultMessage: 'Unmute @{name}' },
  block: { id: 'account.block', defaultMessage: 'Block @{name}' },
  mute: { id: 'account.mute', defaultMessage: 'Mute @{name}' },
  report: { id: 'account.report', defaultMessage: 'Report @{name}' },
  share: { id: 'account.share', defaultMessage: 'Share @{name}\'s profile' },
  copy: { id: 'account.copy', defaultMessage: 'Copy link to profile' },
  media: { id: 'account.media', defaultMessage: 'Media' },
  blockDomain: { id: 'account.block_domain', defaultMessage: 'Block domain {domain}' },
  unblockDomain: { id: 'account.unblock_domain', defaultMessage: 'Unblock domain {domain}' },
  hideReblogs: { id: 'account.hide_reblogs', defaultMessage: 'Hide boosts from @{name}' },
  showReblogs: { id: 'account.show_reblogs', defaultMessage: 'Show boosts from @{name}' },
  enableNotifications: { id: 'account.enable_notifications', defaultMessage: 'Notify me when @{name} posts' },
  disableNotifications: { id: 'account.disable_notifications', defaultMessage: 'Stop notifying me when @{name} posts' },
  pins: { id: 'navigation_bar.pins', defaultMessage: 'Pinned posts' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  follow_requests: { id: 'navigation_bar.follow_requests', defaultMessage: 'Follow requests' },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favorites' },
  lists: { id: 'navigation_bar.lists', defaultMessage: 'Lists' },
  followed_tags: { id: 'navigation_bar.followed_tags', defaultMessage: 'Followed hashtags' },
  blocks: { id: 'navigation_bar.blocks', defaultMessage: 'Blocked users' },
  domain_blocks: { id: 'navigation_bar.domain_blocks', defaultMessage: 'Blocked domains' },
  mutes: { id: 'navigation_bar.mutes', defaultMessage: 'Muted users' },
  endorse: { id: 'account.endorse', defaultMessage: 'Feature on profile' },
  unendorse: { id: 'account.unendorse', defaultMessage: 'Don\'t feature on profile' },
  add_or_remove_from_list: { id: 'account.add_or_remove_from_list', defaultMessage: 'Add or Remove from lists' },
  admin_account: { id: 'status.admin_account', defaultMessage: 'Open moderation interface for @{name}' },
  admin_domain: { id: 'status.admin_domain', defaultMessage: 'Open moderation interface for {domain}' },
  languages: { id: 'account.languages', defaultMessage: 'Change subscribed languages' },
  openOriginalPage: { id: 'account.open_original_page', defaultMessage: 'Open original page' },
});

const titleFromAccount = account => {
  const displayName = account.get('display_name');
  const acct = account.get('acct') === account.get('username') ? `${account.get('username')}@${localDomain}` : account.get('acct');
  const prefix = displayName.trim().length === 0 ? account.get('username') : displayName;

  return `${prefix} (@${acct})`;
};

const messageForFollowButton = relationship => {
  if(!relationship) return messages.follow;

  if (relationship.get('following') && relationship.get('followed_by')) {
    return messages.mutual;
  } else if (relationship.get('following') || relationship.get('requested')) {
    return messages.unfollow;
  } else if (relationship.get('followed_by')) {
    return messages.followBack;
  } else {
    return messages.follow;
  }
};

const dateFormatOptions = {
  month: 'short',
  day: 'numeric',
  year: 'numeric',
  hour: '2-digit',
  minute: '2-digit',
};

class Header extends ImmutablePureComponent {

  static propTypes = {
    identity: identityContextPropShape,
    account: ImmutablePropTypes.record,
    identity_props: ImmutablePropTypes.list,
    onFollow: PropTypes.func.isRequired,
    onBlock: PropTypes.func.isRequired,
    onMention: PropTypes.func.isRequired,
    onDirect: PropTypes.func.isRequired,
    onReblogToggle: PropTypes.func.isRequired,
    onNotifyToggle: PropTypes.func.isRequired,
    onReport: PropTypes.func.isRequired,
    onMute: PropTypes.func.isRequired,
    onBlockDomain: PropTypes.func.isRequired,
    onUnblockDomain: PropTypes.func.isRequired,
    onEndorseToggle: PropTypes.func.isRequired,
    onAddToList: PropTypes.func.isRequired,
    onEditAccountNote: PropTypes.func.isRequired,
    onChangeLanguages: PropTypes.func.isRequired,
    onInteractionModal: PropTypes.func.isRequired,
    onOpenAvatar: PropTypes.func.isRequired,
    onOpenURL: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    domain: PropTypes.string.isRequired,
    hidden: PropTypes.bool,
    ...WithRouterPropTypes,
  };

  setRef = c => {
    this.node = c;
  };

  openEditProfile = () => {
    window.open('/settings/profile', '_blank');
  };

  isStatusesPageActive = (match, location) => {
    if (!match) {
      return false;
    }

    return !location.pathname.match(/\/(followers|following)\/?$/);
  };

  handleMouseEnter = ({ currentTarget }) => {
    if (autoPlayGif) {
      return;
    }

    const emojis = currentTarget.querySelectorAll('.custom-emoji');

    for (var i = 0; i < emojis.length; i++) {
      let emoji = emojis[i];
      emoji.src = emoji.getAttribute('data-original');
    }
  };

  handleMouseLeave = ({ currentTarget }) => {
    if (autoPlayGif) {
      return;
    }

    const emojis = currentTarget.querySelectorAll('.custom-emoji');

    for (var i = 0; i < emojis.length; i++) {
      let emoji = emojis[i];
      emoji.src = emoji.getAttribute('data-static');
    }
  };

  handleAvatarClick = e => {
    if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      this.props.onOpenAvatar();
    }
  };

  handleShare = () => {
    const { account } = this.props;

    navigator.share({
      url: account.get('url'),
    }).catch((e) => {
      if (e.name !== 'AbortError') console.error(e);
    });
  };

  handleHashtagClick = e => {
    const { history } = this.props;
    const value = e.currentTarget.textContent.replace(/^#/, '');

    if (history && e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      history.push(`/tags/${value}`);
    }
  };

  handleMentionClick = e => {
    const { history, onOpenURL } = this.props;

    if (history && e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();

      const link = e.currentTarget;

      onOpenURL(link.href, history, () => {
        window.location = link.href;
      });
    }
  };

  _attachLinkEvents () {
    const node = this.node;

    if (!node) {
      return;
    }

    const links = node.querySelectorAll('a');

    let link;

    for (var i = 0; i < links.length; ++i) {
      link = links[i];

      if (link.textContent[0] === '#' || (link.previousSibling && link.previousSibling.textContent && link.previousSibling.textContent[link.previousSibling.textContent.length - 1] === '#')) {
        link.addEventListener('click', this.handleHashtagClick, false);
      } else if (link.classList.contains('mention')) {
        link.addEventListener('click', this.handleMentionClick, false);
      }
    }
  }

  componentDidMount () {
    this._attachLinkEvents();
  }

  componentDidUpdate () {
    this._attachLinkEvents();
  }

  render () {
    const { account, hidden, intl } = this.props;
    const { signedIn, permissions } = this.props.identity;

    if (!account) {
      return null;
    }

    const suspended    = account.get('suspended');
    const isRemote     = account.get('acct') !== account.get('username');
    const remoteDomain = isRemote ? account.get('acct').split('@')[1] : null;

    let actionBtn, bellBtn, lockedIcon, shareBtn;

    let info = [];
    let menu = [];

    if (me !== account.get('id') && account.getIn(['relationship', 'blocking'])) {
      info.push(<span key='blocked' className='relationship-tag'><FormattedMessage id='account.blocked' defaultMessage='Blocked' /></span>);
    }

    if (me !== account.get('id') && account.getIn(['relationship', 'muting'])) {
      info.push(<span key='muted' className='relationship-tag'><FormattedMessage id='account.muted' defaultMessage='Muted' /></span>);
    } else if (me !== account.get('id') && account.getIn(['relationship', 'domain_blocking'])) {
      info.push(<span key='domain_blocked' className='relationship-tag'><FormattedMessage id='account.domain_blocked' defaultMessage='Domain blocked' /></span>);
    }

    if (account.getIn(['relationship', 'requested']) || account.getIn(['relationship', 'following'])) {
      bellBtn = <IconButton icon={account.getIn(['relationship', 'notifying']) ? 'bell' : 'bell-o'} iconComponent={account.getIn(['relationship', 'notifying']) ? NotificationsActiveIcon : NotificationsIcon} active={account.getIn(['relationship', 'notifying'])} title={intl.formatMessage(account.getIn(['relationship', 'notifying']) ? messages.disableNotifications : messages.enableNotifications, { name: account.get('username') })} onClick={this.props.onNotifyToggle} />;
    }

    if ('share' in navigator) {
      shareBtn = <IconButton className='optional' iconComponent={ShareIcon} title={intl.formatMessage(messages.share, { name: account.get('username') })} onClick={this.handleShare} />;
    } else {
      shareBtn = <CopyIconButton className='optional' title={intl.formatMessage(messages.copy)} value={account.get('url')} />;
    }

    if (me !== account.get('id')) {
      if (signedIn && !account.get('relationship')) { // Wait until the relationship is loaded
        actionBtn = <Button disabled><LoadingIndicator /></Button>;
      } else if (!account.getIn(['relationship', 'blocking'])) {
        actionBtn = <Button disabled={account.getIn(['relationship', 'blocked_by'])} className={classNames({ 'button--destructive': (account.getIn(['relationship', 'following']) || account.getIn(['relationship', 'requested'])) })} text={intl.formatMessage(messageForFollowButton(account.get('relationship')))} onClick={signedIn ? this.props.onFollow : this.props.onInteractionModal} />;
      } else if (account.getIn(['relationship', 'blocking'])) {
        actionBtn = <Button text={intl.formatMessage(messages.unblock, { name: account.get('username') })} onClick={this.props.onBlock} />;
      }
    } else {
      actionBtn = <Button text={intl.formatMessage(messages.edit_profile)} onClick={this.openEditProfile} />;
    }

    if (account.get('moved') && !account.getIn(['relationship', 'following'])) {
      actionBtn = '';
    }

    if (account.get('locked')) {
      lockedIcon = <Icon id='lock' icon={LockIcon} title={intl.formatMessage(messages.account_locked)} />;
    }

    if (signedIn && account.get('id') !== me && !account.get('suspended')) {
      menu.push({ text: intl.formatMessage(messages.mention, { name: account.get('username') }), action: this.props.onMention });
      menu.push({ text: intl.formatMessage(messages.direct, { name: account.get('username') }), action: this.props.onDirect });
      menu.push(null);
    }

    if (isRemote) {
      menu.push({ text: intl.formatMessage(messages.openOriginalPage), href: account.get('url') });
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
      menu.push({ text: intl.formatMessage(messages.followed_tags), to: '/followed_tags' });
      menu.push(null);
      menu.push({ text: intl.formatMessage(messages.mutes), to: '/mutes' });
      menu.push({ text: intl.formatMessage(messages.blocks), to: '/blocks' });
      menu.push({ text: intl.formatMessage(messages.domain_blocks), to: '/domain_blocks' });
    } else if (signedIn) {
      if (account.getIn(['relationship', 'following'])) {
        if (!account.getIn(['relationship', 'muting'])) {
          if (account.getIn(['relationship', 'showing_reblogs'])) {
            menu.push({ text: intl.formatMessage(messages.hideReblogs, { name: account.get('username') }), action: this.props.onReblogToggle });
          } else {
            menu.push({ text: intl.formatMessage(messages.showReblogs, { name: account.get('username') }), action: this.props.onReblogToggle });
          }

          menu.push({ text: intl.formatMessage(messages.languages), action: this.props.onChangeLanguages });
          menu.push(null);
        }

        menu.push({ text: intl.formatMessage(account.getIn(['relationship', 'endorsed']) ? messages.unendorse : messages.endorse), action: this.props.onEndorseToggle });
        menu.push({ text: intl.formatMessage(messages.add_or_remove_from_list), action: this.props.onAddToList });
        menu.push(null);
      }

      if (account.getIn(['relationship', 'muting'])) {
        menu.push({ text: intl.formatMessage(messages.unmute, { name: account.get('username') }), action: this.props.onMute });
      } else {
        menu.push({ text: intl.formatMessage(messages.mute, { name: account.get('username') }), action: this.props.onMute, dangerous: true });
      }

      if (account.getIn(['relationship', 'blocking'])) {
        menu.push({ text: intl.formatMessage(messages.unblock, { name: account.get('username') }), action: this.props.onBlock });
      } else {
        menu.push({ text: intl.formatMessage(messages.block, { name: account.get('username') }), action: this.props.onBlock, dangerous: true });
      }

      if (!account.get('suspended')) {
        menu.push({ text: intl.formatMessage(messages.report, { name: account.get('username') }), action: this.props.onReport, dangerous: true });
      }
    }

    if (signedIn && isRemote) {
      menu.push(null);

      if (account.getIn(['relationship', 'domain_blocking'])) {
        menu.push({ text: intl.formatMessage(messages.unblockDomain, { domain: remoteDomain }), action: this.props.onUnblockDomain });
      } else {
        menu.push({ text: intl.formatMessage(messages.blockDomain, { domain: remoteDomain }), action: this.props.onBlockDomain, dangerous: true });
      }
    }

    if ((account.get('id') !== me && (permissions & PERMISSION_MANAGE_USERS) === PERMISSION_MANAGE_USERS) || (isRemote && (permissions & PERMISSION_MANAGE_FEDERATION) === PERMISSION_MANAGE_FEDERATION)) {
      menu.push(null);
      if ((permissions & PERMISSION_MANAGE_USERS) === PERMISSION_MANAGE_USERS) {
        menu.push({ text: intl.formatMessage(messages.admin_account, { name: account.get('username') }), href: `/admin/accounts/${account.get('id')}` });
      }
      if (isRemote && (permissions & PERMISSION_MANAGE_FEDERATION) === PERMISSION_MANAGE_FEDERATION) {
        menu.push({ text: intl.formatMessage(messages.admin_domain, { domain: remoteDomain }), href: `/admin/instances/${remoteDomain}` });
      }
    }

    const content         = { __html: account.get('note_emojified') };
    const displayNameHtml = { __html: account.get('display_name_html') };
    const fields          = account.get('fields');
    const isLocal         = account.get('acct').indexOf('@') === -1;
    const username        = account.get('acct').split('@')[0];
    const domain          = isLocal ? localDomain : account.get('acct').split('@')[1];
    const isIndexable     = !account.get('noindex');

    const badges = [];

    if (account.get('bot')) {
      badges.push(<AutomatedBadge key='bot-badge' />);
    } else if (account.get('group')) {
      badges.push(<GroupBadge key='group-badge' />);
    }

    account.get('roles', []).forEach((role) => {
      badges.push(<Badge key={`role-badge-${role.get('id')}`} label={<span>{role.get('name')}</span>} domain={domain} roleId={role.get('id')} />);
    });

    return (
      <div className={classNames('account__header', { inactive: !!account.get('moved') })} onMouseEnter={this.handleMouseEnter} onMouseLeave={this.handleMouseLeave}>
        {!(suspended || hidden || account.get('moved')) && account.getIn(['relationship', 'requested_by']) && <FollowRequestNoteContainer account={account} />}

        <div className='account__header__image'>
          <div className='account__header__info'>
            {info}
          </div>

          {!(suspended || hidden) && <img src={autoPlayGif ? account.get('header') : account.get('header_static')} alt='' className='parallax' />}
        </div>

        <div className='account__header__bar'>
          <div className='account__header__tabs'>
            <a className='avatar' href={account.get('avatar')} rel='noopener noreferrer' target='_blank' onClick={this.handleAvatarClick}>
              <Avatar account={suspended || hidden ? undefined : account} size={90} />
            </a>

            <div className='account__header__tabs__buttons'>
              {!hidden && bellBtn}
              {!hidden && shareBtn}
              <DropdownMenuContainer disabled={menu.length === 0} items={menu} icon='ellipsis-v' iconComponent={MoreHorizIcon} size={24} direction='right' />
              {!hidden && actionBtn}
            </div>
          </div>

          <div className='account__header__tabs__name'>
            <h1>
              <span dangerouslySetInnerHTML={displayNameHtml} />
              <small>
                <span>@{username}<span className='invisible'>@{domain}</span></span>
                <DomainPill username={username} domain={domain} isSelf={me === account.get('id')} />
                {lockedIcon}
              </small>
            </h1>
          </div>

          {badges.length > 0 && (
            <div className='account__header__badges'>
              {badges}
            </div>
          )}

          {!(suspended || hidden) && (
            <div className='account__header__extra'>
              <div className='account__header__bio' ref={this.setRef}>
                {(account.get('id') !== me && signedIn) && <AccountNoteContainer account={account} />}

                {account.get('note').length > 0 && account.get('note') !== '<p></p>' && <div className='account__header__content translate' dangerouslySetInnerHTML={content} />}

                <div className='account__header__fields'>
                  <dl>
                    <dt><FormattedMessage id='account.joined_short' defaultMessage='Joined' /></dt>
                    <dd>{intl.formatDate(account.get('created_at'), { year: 'numeric', month: 'short', day: '2-digit' })}</dd>
                  </dl>

                  {fields.map((pair, i) => (
                    <dl key={i} className={classNames({ verified: pair.get('verified_at') })}>
                      <dt dangerouslySetInnerHTML={{ __html: pair.get('name_emojified') }} title={pair.get('name')} className='translate' />

                      <dd className='translate' title={pair.get('value_plain')}>
                        {pair.get('verified_at') && <span title={intl.formatMessage(messages.linkVerifiedOn, { date: intl.formatDate(pair.get('verified_at'), dateFormatOptions) })}><Icon id='check' icon={CheckIcon} className='verified__mark' /></span>} <span dangerouslySetInnerHTML={{ __html: pair.get('value_emojified') }} />
                      </dd>
                    </dl>
                  ))}
                </div>
              </div>

              <div className='account__header__extra__links'>
                <NavLink isActive={this.isStatusesPageActive} activeClassName='active' to={`/@${account.get('acct')}`} title={intl.formatNumber(account.get('statuses_count'))}>
                  <ShortNumber
                    value={account.get('statuses_count')}
                    renderer={StatusesCounter}
                  />
                </NavLink>

                <NavLink exact activeClassName='active' to={`/@${account.get('acct')}/following`} title={intl.formatNumber(account.get('following_count'))}>
                  <ShortNumber
                    value={account.get('following_count')}
                    renderer={FollowingCounter}
                  />
                </NavLink>

                <NavLink exact activeClassName='active' to={`/@${account.get('acct')}/followers`} title={intl.formatNumber(account.get('followers_count'))}>
                  <ShortNumber
                    value={account.get('followers_count')}
                    renderer={FollowersCounter}
                  />
                </NavLink>
              </div>
            </div>
          )}
        </div>

        <Helmet>
          <title>{titleFromAccount(account)}</title>
          <meta name='robots' content={(isLocal && isIndexable) ? 'all' : 'noindex'} />
          <link rel='canonical' href={account.get('url')} />
        </Helmet>
      </div>
    );
  }

}

export default withRouter(withIdentity(injectIntl(Header)));

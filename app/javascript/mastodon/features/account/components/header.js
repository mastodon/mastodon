import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import Button from 'mastodon/components/button';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { autoPlayGif, me, isStaff } from 'mastodon/initial_state';
import classNames from 'classnames';
import Icon from 'mastodon/components/icon';
import Avatar from 'mastodon/components/avatar';
import { shortNumberFormat } from 'mastodon/utils/numbers';
import { NavLink } from 'react-router-dom';
import DropdownMenuContainer from 'mastodon/containers/dropdown_menu_container';
import IconButton from 'mastodon/components/icon_button';

const messages = defineMessages({
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  cancel_follow_request: { id: 'account.cancel_follow_request', defaultMessage: 'Cancel follow request' },
  requested: { id: 'account.requested', defaultMessage: 'Awaiting approval. Click to cancel follow request' },
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock @{name}' },
  edit_profile: { id: 'account.edit_profile', defaultMessage: 'Edit profile' },
  linkVerifiedOn: { id: 'account.link_verified_on', defaultMessage: 'Ownership of this link was checked on {date}' },
  account_locked: { id: 'account.locked_info', defaultMessage: 'This account privacy status is set to locked. The owner manually reviews who can follow them.' },
  mention: { id: 'account.mention', defaultMessage: 'Mention @{name}' },
  direct: { id: 'account.direct', defaultMessage: 'Direct message @{name}' },
  unmute: { id: 'account.unmute', defaultMessage: 'Unmute @{name}' },
  block: { id: 'account.block', defaultMessage: 'Block @{name}' },
  mute: { id: 'account.mute', defaultMessage: 'Mute @{name}' },
  report: { id: 'account.report', defaultMessage: 'Report @{name}' },
  share: { id: 'account.share', defaultMessage: 'Share @{name}\'s profile' },
  media: { id: 'account.media', defaultMessage: 'Media' },
  blockDomain: { id: 'account.block_domain', defaultMessage: 'Block domain {domain}' },
  unblockDomain: { id: 'account.unblock_domain', defaultMessage: 'Unblock domain {domain}' },
  hideReblogs: { id: 'account.hide_reblogs', defaultMessage: 'Hide boosts from @{name}' },
  showReblogs: { id: 'account.show_reblogs', defaultMessage: 'Show boosts from @{name}' },
  pins: { id: 'navigation_bar.pins', defaultMessage: 'Pinned toots' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  follow_requests: { id: 'navigation_bar.follow_requests', defaultMessage: 'Follow requests' },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favourites' },
  lists: { id: 'navigation_bar.lists', defaultMessage: 'Lists' },
  blocks: { id: 'navigation_bar.blocks', defaultMessage: 'Blocked users' },
  domain_blocks: { id: 'navigation_bar.domain_blocks', defaultMessage: 'Blocked domains' },
  mutes: { id: 'navigation_bar.mutes', defaultMessage: 'Muted users' },
  endorse: { id: 'account.endorse', defaultMessage: 'Feature on profile' },
  unendorse: { id: 'account.unendorse', defaultMessage: 'Don\'t feature on profile' },
  add_or_remove_from_list: { id: 'account.add_or_remove_from_list', defaultMessage: 'Add or Remove from lists' },
  admin_account: { id: 'status.admin_account', defaultMessage: 'Open moderation interface for @{name}' },
  add_user_note: { id: 'account.add_user_note', defaultMessage: 'Add note for @{name}' },
  edit_user_note: { id: 'account.edit_user_note', defaultMessage: 'Edit note for @{name}' },
});

const dateFormatOptions = {
  month: 'short',
  day: 'numeric',
  year: 'numeric',
  hour12: false,
  hour: '2-digit',
  minute: '2-digit',
};

export default @injectIntl
class Header extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map,
    identity_props: ImmutablePropTypes.list,
    onFollow: PropTypes.func.isRequired,
    onBlock: PropTypes.func.isRequired,
    onEditUserNote: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    domain: PropTypes.string.isRequired,
  };

  openEditProfile = () => {
    window.open('/settings/profile', '_blank');
  }

  isStatusesPageActive = (match, location) => {
    if (!match) {
      return false;
    }

    return !location.pathname.match(/\/(followers|following)\/?$/);
  }

  _updateEmojis () {
    const node = this.node;

    if (!node || autoPlayGif) {
      return;
    }

    const emojis = node.querySelectorAll('.custom-emoji');

    for (var i = 0; i < emojis.length; i++) {
      let emoji = emojis[i];
      if (emoji.classList.contains('status-emoji')) {
        continue;
      }
      emoji.classList.add('status-emoji');

      emoji.addEventListener('mouseenter', this.handleEmojiMouseEnter, false);
      emoji.addEventListener('mouseleave', this.handleEmojiMouseLeave, false);
    }
  }

  componentDidMount () {
    this._updateEmojis();
  }

  componentDidUpdate () {
    this._updateEmojis();
  }

  handleEmojiMouseEnter = ({ target }) => {
    target.src = target.getAttribute('data-original');
  }

  handleEmojiMouseLeave = ({ target }) => {
    target.src = target.getAttribute('data-static');
  }

  setRef = (c) => {
    this.node = c;
  }

  render () {
    const { account, intl, domain, identity_proofs } = this.props;

    if (!account) {
      return null;
    }

    const userNote = account.getIn(['relationship', 'comment']);

    let info        = [];
    let actionBtn   = '';
    let lockedIcon  = '';
    let menu        = [];

    if (me !== account.get('id') && account.getIn(['relationship', 'followed_by'])) {
      info.push(<span key='followed_by' className='relationship-tag'><FormattedMessage id='account.follows_you' defaultMessage='Follows you' /></span>);
    } else if (me !== account.get('id') && account.getIn(['relationship', 'blocking'])) {
      info.push(<span key='blocked' className='relationship-tag'><FormattedMessage id='account.blocked' defaultMessage='Blocked' /></span>);
    }

    if (me !== account.get('id') && account.getIn(['relationship', 'muting'])) {
      info.push(<span key='muted' className='relationship-tag'><FormattedMessage id='account.muted' defaultMessage='Muted' /></span>);
    } else if (me !== account.get('id') && account.getIn(['relationship', 'domain_blocking'])) {
      info.push(<span key='domain_blocked' className='relationship-tag'><FormattedMessage id='account.domain_blocked' defaultMessage='Domain blocked' /></span>);
    }

    if (me !== account.get('id')) {
      if (!account.get('relationship')) { // Wait until the relationship is loaded
        actionBtn = '';
      } else if (account.getIn(['relationship', 'requested'])) {
        actionBtn = <Button className='logo-button' text={intl.formatMessage(messages.cancel_follow_request)} title={intl.formatMessage(messages.requested)} onClick={this.props.onFollow} />;
      } else if (!account.getIn(['relationship', 'blocking'])) {
        actionBtn = <Button disabled={account.getIn(['relationship', 'blocked_by'])} className={classNames('logo-button', { 'button--destructive': account.getIn(['relationship', 'following']) })} text={intl.formatMessage(account.getIn(['relationship', 'following']) ? messages.unfollow : messages.follow)} onClick={this.props.onFollow} />;
      } else if (account.getIn(['relationship', 'blocking'])) {
        actionBtn = <Button className='logo-button' text={intl.formatMessage(messages.unblock, { name: account.get('username') })} onClick={this.props.onBlock} />;
      }
    } else {
      actionBtn = <Button className='logo-button' text={intl.formatMessage(messages.edit_profile)} onClick={this.openEditProfile} />;
    }

    if (account.get('moved') && !account.getIn(['relationship', 'following'])) {
      actionBtn = '';
    }

    if (account.get('locked')) {
      lockedIcon = <Icon id='lock' title={intl.formatMessage(messages.account_locked)} />;
    }

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
        if (!account.getIn(['relationship', 'muting'])) {
          if (account.getIn(['relationship', 'showing_reblogs'])) {
            menu.push({ text: intl.formatMessage(messages.hideReblogs, { name: account.get('username') }), action: this.props.onReblogToggle });
          } else {
            menu.push({ text: intl.formatMessage(messages.showReblogs, { name: account.get('username') }), action: this.props.onReblogToggle });
          }
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

      if (userNote === null) {
        menu.push({ text: intl.formatMessage(messages.add_user_note, { name: account.get('username') }), action: this.props.onEditUserNote });
      }

      menu.push({ text: intl.formatMessage(messages.report, { name: account.get('username') }), action: this.props.onReport });
    }

    if (account.get('acct') !== account.get('username')) {
      const domain = account.get('acct').split('@')[1];

      menu.push(null);

      if (account.getIn(['relationship', 'domain_blocking'])) {
        menu.push({ text: intl.formatMessage(messages.unblockDomain, { domain }), action: this.props.onUnblockDomain });
      } else {
        menu.push({ text: intl.formatMessage(messages.blockDomain, { domain }), action: this.props.onBlockDomain });
      }
    }

    if (account.get('id') !== me && isStaff) {
      menu.push(null);
      menu.push({ text: intl.formatMessage(messages.admin_account, { name: account.get('username') }), href: `/admin/accounts/${account.get('id')}` });
    }

    const content         = { __html: account.get('note_emojified') };
    const displayNameHtml = { __html: account.get('display_name_html') };
    const fields          = account.get('fields');
    const acct            = account.get('acct').indexOf('@') === -1 && domain ? `${account.get('acct')}@${domain}` : account.get('acct');

    let badge;

    if (account.get('bot')) {
      badge = (<div className='account-role bot'><FormattedMessage id='account.badges.bot' defaultMessage='Bot' /></div>);
    } else if (account.get('group')) {
      badge = (<div className='account-role group'><FormattedMessage id='account.badges.group' defaultMessage='Group' /></div>);
    } else {
      badge = null;
    }

    return (
      <div className={classNames('account__header', { inactive: !!account.get('moved') })} ref={this.setRef}>
        <div className='account__header__image'>
          <div className='account__header__info'>
            {info}
          </div>

          <img src={autoPlayGif ? account.get('header') : account.get('header_static')} alt='' className='parallax' />
        </div>

        <div className='account__header__bar'>
          <div className='account__header__tabs'>
            <a className='avatar' href={account.get('url')} rel='noopener noreferrer' target='_blank'>
              <Avatar account={account} size={90} />
            </a>

            <div className='spacer' />

            <div className='account__header__tabs__buttons'>
              {actionBtn}

              <DropdownMenuContainer items={menu} icon='ellipsis-v' size={24} direction='right' />
            </div>
          </div>

          <div className='account__header__tabs__name'>
            <h1>
              <span dangerouslySetInnerHTML={displayNameHtml} /> {badge}
              <small>@{acct} {lockedIcon}</small>
            </h1>
          </div>

          {!!userNote && (
            <div className='account__header__user-note'>
              <div className='account__header__user-note__header'>
                <strong><FormattedMessage id='account.user_note_header' defaultMessage='Your note for @{name}' values={{ name: account.get('username') }} /></strong>
                <IconButton icon='pencil' title={intl.formatMessage(messages.edit_user_note, { name: account.get('username') })} onClick={this.props.onEditUserNote} size={15} />
              </div>
              <span>{userNote}</span>
            </div>
          )}

          <div className='account__header__extra'>
            <div className='account__header__bio'>
              { (fields.size > 0 || identity_proofs.size > 0) && (
                <div className='account__header__fields'>
                  {identity_proofs.map((proof, i) => (
                    <dl key={i}>
                      <dt dangerouslySetInnerHTML={{ __html: proof.get('provider') }} />

                      <dd className='verified'>
                        <a href={proof.get('proof_url')} target='_blank' rel='noopener noreferrer'><span title={intl.formatMessage(messages.linkVerifiedOn, { date: intl.formatDate(proof.get('updated_at'), dateFormatOptions) })}>
                          <Icon id='check' className='verified__mark' />
                        </span></a>
                        <a href={proof.get('profile_url')} target='_blank' rel='noopener noreferrer'><span dangerouslySetInnerHTML={{ __html: ' '+proof.get('provider_username') }} /></a>
                      </dd>
                    </dl>
                  ))}
                  {fields.map((pair, i) => (
                    <dl key={i}>
                      <dt dangerouslySetInnerHTML={{ __html: pair.get('name_emojified') }} title={pair.get('name')} />

                      <dd className={pair.get('verified_at') && 'verified'} title={pair.get('value_plain')}>
                        {pair.get('verified_at') && <span title={intl.formatMessage(messages.linkVerifiedOn, { date: intl.formatDate(pair.get('verified_at'), dateFormatOptions) })}><Icon id='check' className='verified__mark' /></span>} <span dangerouslySetInnerHTML={{ __html: pair.get('value_emojified') }} />
                      </dd>
                    </dl>
                  ))}
                </div>
              )}

              {account.get('note').length > 0 && account.get('note') !== '<p></p>' && <div className='account__header__content' dangerouslySetInnerHTML={content} />}
            </div>

            <div className='account__header__extra__links'>
              <NavLink isActive={this.isStatusesPageActive} activeClassName='active' to={`/accounts/${account.get('id')}`} title={intl.formatNumber(account.get('statuses_count'))}>
                <strong>{shortNumberFormat(account.get('statuses_count'))}</strong> <FormattedMessage id='account.posts' defaultMessage='Toots' />
              </NavLink>

              <NavLink exact activeClassName='active' to={`/accounts/${account.get('id')}/following`} title={intl.formatNumber(account.get('following_count'))}>
                <strong>{shortNumberFormat(account.get('following_count'))}</strong> <FormattedMessage id='account.follows' defaultMessage='Follows' />
              </NavLink>

              <NavLink exact activeClassName='active' to={`/accounts/${account.get('id')}/followers`} title={intl.formatNumber(account.get('followers_count'))}>
                <strong>{shortNumberFormat(account.get('followers_count'))}</strong> <FormattedMessage id='account.followers' defaultMessage='Followers' />
              </NavLink>
            </div>
          </div>
        </div>
      </div>
    );
  }

}

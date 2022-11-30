import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import IconButton from './icon_button';
import DropdownMenuContainer from '../containers/dropdown_menu_container';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { me } from '../initial_state';
import classNames from 'classnames';
import { PERMISSION_MANAGE_USERS, PERMISSION_MANAGE_FEDERATION } from 'mastodon/permissions';

const messages = defineMessages({
  delete: { id: 'status.delete', defaultMessage: 'Delete' },
  redraft: { id: 'status.redraft', defaultMessage: 'Delete & re-draft' },
  edit: { id: 'status.edit', defaultMessage: 'Edit' },
  direct: { id: 'status.direct', defaultMessage: 'Direct message @{name}' },
  mention: { id: 'status.mention', defaultMessage: 'Mention @{name}' },
  mute: { id: 'account.mute', defaultMessage: 'Mute @{name}' },
  block: { id: 'account.block', defaultMessage: 'Block @{name}' },
  reply: { id: 'status.reply', defaultMessage: 'Reply' },
  share: { id: 'status.share', defaultMessage: 'Share' },
  more: { id: 'status.more', defaultMessage: 'More' },
  replyAll: { id: 'status.replyAll', defaultMessage: 'Reply to thread' },
  reblog: { id: 'status.reblog', defaultMessage: 'Boost' },
  reblog_private: { id: 'status.reblog_private', defaultMessage: 'Boost with original visibility' },
  cancel_reblog_private: { id: 'status.cancel_reblog_private', defaultMessage: 'Unboost' },
  cannot_reblog: { id: 'status.cannot_reblog', defaultMessage: 'This post cannot be boosted' },
  favourite: { id: 'status.favourite', defaultMessage: 'Favourite' },
  bookmark: { id: 'status.bookmark', defaultMessage: 'Bookmark' },
  removeBookmark: { id: 'status.remove_bookmark', defaultMessage: 'Remove bookmark' },
  open: { id: 'status.open', defaultMessage: 'Expand this status' },
  report: { id: 'status.report', defaultMessage: 'Report @{name}' },
  muteConversation: { id: 'status.mute_conversation', defaultMessage: 'Mute conversation' },
  unmuteConversation: { id: 'status.unmute_conversation', defaultMessage: 'Unmute conversation' },
  pin: { id: 'status.pin', defaultMessage: 'Pin on profile' },
  unpin: { id: 'status.unpin', defaultMessage: 'Unpin from profile' },
  embed: { id: 'status.embed', defaultMessage: 'Embed' },
  admin_account: { id: 'status.admin_account', defaultMessage: 'Open moderation interface for @{name}' },
  admin_status: { id: 'status.admin_status', defaultMessage: 'Open this post in the moderation interface' },
  admin_domain: { id: 'status.admin_domain', defaultMessage: 'Open moderation interface for {domain}' },
  copy: { id: 'status.copy', defaultMessage: 'Copy link to post' },
  hide: { id: 'status.hide', defaultMessage: 'Hide post' },
  blockDomain: { id: 'account.block_domain', defaultMessage: 'Block domain {domain}' },
  unblockDomain: { id: 'account.unblock_domain', defaultMessage: 'Unblock domain {domain}' },
  unmute: { id: 'account.unmute', defaultMessage: 'Unmute @{name}' },
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock @{name}' },
  filter: { id: 'status.filter', defaultMessage: 'Filter this post' },
  openOriginalPage: { id: 'account.open_original_page', defaultMessage: 'Open original page' },
});

const mapStateToProps = (state, { status }) => ({
  relationship: state.getIn(['relationships', status.getIn(['account', 'id'])]),
});

export default @connect(mapStateToProps)
@injectIntl
class StatusActionBar extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
    identity: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    relationship: ImmutablePropTypes.map,
    onReply: PropTypes.func,
    onFavourite: PropTypes.func,
    onReblog: PropTypes.func,
    onDelete: PropTypes.func,
    onDirect: PropTypes.func,
    onMention: PropTypes.func,
    onMute: PropTypes.func,
    onUnmute: PropTypes.func,
    onBlock: PropTypes.func,
    onUnblock: PropTypes.func,
    onBlockDomain: PropTypes.func,
    onUnblockDomain: PropTypes.func,
    onReport: PropTypes.func,
    onEmbed: PropTypes.func,
    onMuteConversation: PropTypes.func,
    onPin: PropTypes.func,
    onBookmark: PropTypes.func,
    onFilter: PropTypes.func,
    onAddFilter: PropTypes.func,
    onInteractionModal: PropTypes.func,
    withDismiss: PropTypes.bool,
    withCounters: PropTypes.bool,
    scrollKey: PropTypes.string,
    intl: PropTypes.object.isRequired,
  };

  // Avoid checking props that are functions (and whose equality will always
  // evaluate to false. See react-immutable-pure-component for usage.
  updateOnProps = [
    'status',
    'relationship',
    'withDismiss',
  ]

  handleReplyClick = () => {
    const { signedIn } = this.context.identity;

    if (signedIn) {
      this.props.onReply(this.props.status, this.context.router.history);
    } else {
      this.props.onInteractionModal('reply', this.props.status);
    }
  }

  handleShareClick = () => {
    navigator.share({
      text: this.props.status.get('search_index'),
      url: this.props.status.get('url'),
    }).catch((e) => {
      if (e.name !== 'AbortError') console.error(e);
    });
  }

  handleFavouriteClick = () => {
    const { signedIn } = this.context.identity;

    if (signedIn) {
      this.props.onFavourite(this.props.status);
    } else {
      this.props.onInteractionModal('favourite', this.props.status);
    }
  }

  handleReblogClick = e => {
    const { signedIn } = this.context.identity;

    if (signedIn) {
      this.props.onReblog(this.props.status, e);
    } else {
      this.props.onInteractionModal('reblog', this.props.status);
    }
  }

  handleBookmarkClick = () => {
    this.props.onBookmark(this.props.status);
  }

  handleDeleteClick = () => {
    this.props.onDelete(this.props.status, this.context.router.history);
  }

  handleRedraftClick = () => {
    this.props.onDelete(this.props.status, this.context.router.history, true);
  }

  handleEditClick = () => {
    this.props.onEdit(this.props.status, this.context.router.history);
  }

  handlePinClick = () => {
    this.props.onPin(this.props.status);
  }

  handleMentionClick = () => {
    this.props.onMention(this.props.status.get('account'), this.context.router.history);
  }

  handleDirectClick = () => {
    this.props.onDirect(this.props.status.get('account'), this.context.router.history);
  }

  handleMuteClick = () => {
    const { status, relationship, onMute, onUnmute } = this.props;
    const account = status.get('account');

    if (relationship && relationship.get('muting')) {
      onUnmute(account);
    } else {
      onMute(account);
    }
  }

  handleBlockClick = () => {
    const { status, relationship, onBlock, onUnblock } = this.props;
    const account = status.get('account');

    if (relationship && relationship.get('blocking')) {
      onUnblock(account);
    } else {
      onBlock(status);
    }
  }

  handleBlockDomain = () => {
    const { status, onBlockDomain } = this.props;
    const account = status.get('account');

    onBlockDomain(account.get('acct').split('@')[1]);
  }

  handleUnblockDomain = () => {
    const { status, onUnblockDomain } = this.props;
    const account = status.get('account');

    onUnblockDomain(account.get('acct').split('@')[1]);
  }

  handleOpen = () => {
    this.context.router.history.push(`/@${this.props.status.getIn(['account', 'acct'])}/${this.props.status.get('id')}`);
  }

  handleEmbed = () => {
    this.props.onEmbed(this.props.status);
  }

  handleReport = () => {
    this.props.onReport(this.props.status);
  }

  handleConversationMuteClick = () => {
    this.props.onMuteConversation(this.props.status);
  }

  handleFilterClick = () => {
    this.props.onAddFilter(this.props.status);
  }

  handleCopy = () => {
    const url = this.props.status.get('url');
    navigator.clipboard.writeText(url);
  }

  handleHideClick = () => {
    this.props.onFilter();
  }

  render () {
    const { status, relationship, intl, withDismiss, withCounters, scrollKey } = this.props;
    const { signedIn, permissions } = this.context.identity;

    const anonymousAccess    = !signedIn;
    const publicStatus       = ['public', 'unlisted'].includes(status.get('visibility'));
    const pinnableStatus     = ['public', 'unlisted', 'private'].includes(status.get('visibility'));
    const mutingConversation = status.get('muted');
    const account            = status.get('account');
    const writtenByMe        = status.getIn(['account', 'id']) === me;
    const isRemote           = status.getIn(['account', 'username']) !== status.getIn(['account', 'acct']);

    let menu = [];

    menu.push({ text: intl.formatMessage(messages.open), action: this.handleOpen });

    if (publicStatus && isRemote) {
      menu.push({ text: intl.formatMessage(messages.openOriginalPage), href: status.get('url') });
    }

    menu.push({ text: intl.formatMessage(messages.copy), action: this.handleCopy });

    if (publicStatus) {
      menu.push({ text: intl.formatMessage(messages.embed), action: this.handleEmbed });
    }

    menu.push(null);

    menu.push({ text: intl.formatMessage(status.get('bookmarked') ? messages.removeBookmark : messages.bookmark), action: this.handleBookmarkClick });

    if (writtenByMe && pinnableStatus) {
      menu.push({ text: intl.formatMessage(status.get('pinned') ? messages.unpin : messages.pin), action: this.handlePinClick });
    }

    menu.push(null);

    if (writtenByMe || withDismiss) {
      menu.push({ text: intl.formatMessage(mutingConversation ? messages.unmuteConversation : messages.muteConversation), action: this.handleConversationMuteClick });
      menu.push(null);
    }

    if (writtenByMe) {
      menu.push({ text: intl.formatMessage(messages.edit), action: this.handleEditClick });
      menu.push({ text: intl.formatMessage(messages.delete), action: this.handleDeleteClick });
      menu.push({ text: intl.formatMessage(messages.redraft), action: this.handleRedraftClick });
    } else {
      menu.push({ text: intl.formatMessage(messages.mention, { name: account.get('username') }), action: this.handleMentionClick });
      menu.push({ text: intl.formatMessage(messages.direct, { name: account.get('username') }), action: this.handleDirectClick });
      menu.push(null);

      if (relationship && relationship.get('muting')) {
        menu.push({ text: intl.formatMessage(messages.unmute, { name: account.get('username') }), action: this.handleMuteClick });
      } else {
        menu.push({ text: intl.formatMessage(messages.mute, { name: account.get('username') }), action: this.handleMuteClick });
      }

      if (relationship && relationship.get('blocking')) {
        menu.push({ text: intl.formatMessage(messages.unblock, { name: account.get('username') }), action: this.handleBlockClick });
      } else {
        menu.push({ text: intl.formatMessage(messages.block, { name: account.get('username') }), action: this.handleBlockClick });
      }

      if (!this.props.onFilter) {
        menu.push(null);
        menu.push({ text: intl.formatMessage(messages.filter), action: this.handleFilterClick });
        menu.push(null);
      }

      menu.push({ text: intl.formatMessage(messages.report, { name: account.get('username') }), action: this.handleReport });

      if (account.get('acct') !== account.get('username')) {
        const domain = account.get('acct').split('@')[1];

        menu.push(null);

        if (relationship && relationship.get('domain_blocking')) {
          menu.push({ text: intl.formatMessage(messages.unblockDomain, { domain }), action: this.handleUnblockDomain });
        } else {
          menu.push({ text: intl.formatMessage(messages.blockDomain, { domain }), action: this.handleBlockDomain });
        }
      }

      if ((permissions & PERMISSION_MANAGE_USERS) === PERMISSION_MANAGE_USERS || (isRemote && (permissions & PERMISSION_MANAGE_FEDERATION) === PERMISSION_MANAGE_FEDERATION)) {
        menu.push(null);
        if ((permissions & PERMISSION_MANAGE_USERS) === PERMISSION_MANAGE_USERS) {
          menu.push({ text: intl.formatMessage(messages.admin_account, { name: account.get('username') }), href: `/admin/accounts/${status.getIn(['account', 'id'])}` });
          menu.push({ text: intl.formatMessage(messages.admin_status), href: `/admin/accounts/${status.getIn(['account', 'id'])}/statuses/${status.get('id')}` });
        }
        if (isRemote && (permissions & PERMISSION_MANAGE_FEDERATION) === PERMISSION_MANAGE_FEDERATION) {
          const domain = account.get('acct').split('@')[1];
          menu.push({ text: intl.formatMessage(messages.admin_domain, { domain: domain }), href: `/admin/instances/${domain}` });
        }
      }
    }

    let replyIcon;
    let replyTitle;
    if (status.get('in_reply_to_id', null) === null) {
      replyIcon = 'reply';
      replyTitle = intl.formatMessage(messages.reply);
    } else {
      replyIcon = 'reply-all';
      replyTitle = intl.formatMessage(messages.replyAll);
    }

    const reblogPrivate = status.getIn(['account', 'id']) === me && status.get('visibility') === 'private';

    let reblogTitle = '';
    if (status.get('reblogged')) {
      reblogTitle = intl.formatMessage(messages.cancel_reblog_private);
    } else if (publicStatus) {
      reblogTitle = intl.formatMessage(messages.reblog);
    } else if (reblogPrivate) {
      reblogTitle = intl.formatMessage(messages.reblog_private);
    } else {
      reblogTitle = intl.formatMessage(messages.cannot_reblog);
    }

    const shareButton = ('share' in navigator) && publicStatus && (
      <IconButton className='status__action-bar__button' title={intl.formatMessage(messages.share)} icon='share-alt' onClick={this.handleShareClick} />
    );

    const filterButton = this.props.onFilter && (
      <IconButton className='status__action-bar__button' title={intl.formatMessage(messages.hide)} icon='eye' onClick={this.handleHideClick} />
    );

    return (
      <div className='status__action-bar'>
        <IconButton className='status__action-bar__button' title={replyTitle} icon={status.get('in_reply_to_account_id') === status.getIn(['account', 'id']) ? 'reply' : replyIcon} onClick={this.handleReplyClick} counter={status.get('replies_count')} obfuscateCount />
        <IconButton className={classNames('status__action-bar__button', { reblogPrivate })} disabled={!publicStatus && !reblogPrivate} active={status.get('reblogged')} title={reblogTitle} icon='retweet' onClick={this.handleReblogClick} counter={withCounters ? status.get('reblogs_count') : undefined} />
        <IconButton className='status__action-bar__button star-icon' animate active={status.get('favourited')} title={intl.formatMessage(messages.favourite)} icon='star' onClick={this.handleFavouriteClick} counter={withCounters ? status.get('favourites_count') : undefined} />
        <IconButton className='status__action-bar__button bookmark-icon' disabled={!signedIn} active={status.get('bookmarked')} title={intl.formatMessage(messages.bookmark)} icon='bookmark' onClick={this.handleBookmarkClick} />

        {shareButton}

        {filterButton}

        <div className='status__action-bar__dropdown'>
          <DropdownMenuContainer
            scrollKey={scrollKey}
            disabled={anonymousAccess}
            status={status}
            items={menu}
            icon='ellipsis-h'
            size={18}
            direction='right'
            title={intl.formatMessage(messages.more)}
          />
        </div>
      </div>
    );
  }

}

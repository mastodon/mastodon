import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import IconButton from './icon_button';
import DropdownMenuContainer from 'flavours/glitch/containers/dropdown_menu_container';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { me } from 'flavours/glitch/initial_state';
import RelativeTimestamp from './relative_timestamp';
import { accountAdminLink, statusAdminLink } from 'flavours/glitch/utils/backend_links';
import classNames from 'classnames';
import { PERMISSION_MANAGE_USERS } from 'flavours/glitch/permissions';

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
  open: { id: 'status.open', defaultMessage: 'Expand this status' },
  report: { id: 'status.report', defaultMessage: 'Report @{name}' },
  muteConversation: { id: 'status.mute_conversation', defaultMessage: 'Mute conversation' },
  unmuteConversation: { id: 'status.unmute_conversation', defaultMessage: 'Unmute conversation' },
  pin: { id: 'status.pin', defaultMessage: 'Pin on profile' },
  unpin: { id: 'status.unpin', defaultMessage: 'Unpin from profile' },
  embed: { id: 'status.embed', defaultMessage: 'Embed' },
  admin_account: { id: 'status.admin_account', defaultMessage: 'Open moderation interface for @{name}' },
  admin_status: { id: 'status.admin_status', defaultMessage: 'Open this status in the moderation interface' },
  copy: { id: 'status.copy', defaultMessage: 'Copy link to status' },
  hide: { id: 'status.hide', defaultMessage: 'Hide toot' },
  edited: { id: 'status.edited', defaultMessage: 'Edited {date}' },
  filter: { id: 'status.filter', defaultMessage: 'Filter this post' },
  openOriginalPage: { id: 'account.open_original_page', defaultMessage: 'Open original page' },
});

export default @injectIntl
class StatusActionBar extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
    identity: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    onReply: PropTypes.func,
    onFavourite: PropTypes.func,
    onReblog: PropTypes.func,
    onDelete: PropTypes.func,
    onDirect: PropTypes.func,
    onMention: PropTypes.func,
    onMute: PropTypes.func,
    onBlock: PropTypes.func,
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
    showReplyCount: PropTypes.bool,
    scrollKey: PropTypes.string,
    intl: PropTypes.object.isRequired,
  };

  // Avoid checking props that are functions (and whose equality will always
  // evaluate to false. See react-immutable-pure-component for usage.
  updateOnProps = [
    'status',
    'showReplyCount',
    'withCounters',
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
    });
  }

  handleFavouriteClick = (e) => {
    const { signedIn } = this.context.identity;

    if (signedIn) {
      this.props.onFavourite(this.props.status, e);
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

  handleBookmarkClick = (e) => {
    this.props.onBookmark(this.props.status, e);
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
    this.props.onMute(this.props.status.get('account'));
  }

  handleBlockClick = () => {
    this.props.onBlock(this.props.status);
  }

  handleOpen = () => {
    let state = {...this.context.router.history.location.state};
    if (state.mastodonModalKey) {
      this.context.router.history.replace(`/@${this.props.status.getIn(['account', 'acct'])}/${this.props.status.get('id')}`, { mastodonBackSteps: (state.mastodonBackSteps || 0) + 1 });
    } else {
      state.mastodonBackSteps = (state.mastodonBackSteps || 0) + 1;
      this.context.router.history.push(`/@${this.props.status.getIn(['account', 'acct'])}/${this.props.status.get('id')}`, state);
    }
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

  handleCopy = () => {
    const url = this.props.status.get('url');
    navigator.clipboard.writeText(url);
  }

  handleHideClick = () => {
    this.props.onFilter();
  }

  handleFilterClick = () => {
    this.props.onAddFilter(this.props.status);
  }

  render () {
    const { status, intl, withDismiss, withCounters, showReplyCount, scrollKey } = this.props;

    const anonymousAccess    = !me;
    const mutingConversation = status.get('muted');
    const publicStatus       = ['public', 'unlisted'].includes(status.get('visibility'));
    const pinnableStatus     = ['public', 'unlisted', 'private'].includes(status.get('visibility'));
    const writtenByMe        = status.getIn(['account', 'id']) === me;
    const isRemote           = status.getIn(['account', 'username']) !== status.getIn(['account', 'acct']);

    let menu = [];
    let reblogIcon = 'retweet';
    let replyIcon;
    let replyTitle;

    menu.push({ text: intl.formatMessage(messages.open), action: this.handleOpen });

    if (publicStatus) {
      if (isRemote) {
        menu.push({ text: intl.formatMessage(messages.openOriginalPage), href: status.get('url') });
      }
      menu.push({ text: intl.formatMessage(messages.copy), action: this.handleCopy });
      menu.push({ text: intl.formatMessage(messages.embed), action: this.handleEmbed });
    }

    menu.push(null);

    if (writtenByMe && pinnableStatus) {
      menu.push({ text: intl.formatMessage(status.get('pinned') ? messages.unpin : messages.pin), action: this.handlePinClick });
      menu.push(null);
    }

    if (writtenByMe || withDismiss) {
      menu.push({ text: intl.formatMessage(mutingConversation ? messages.unmuteConversation : messages.muteConversation), action: this.handleConversationMuteClick });
      menu.push(null);
    }

    if (writtenByMe) {
      menu.push({ text: intl.formatMessage(messages.edit), action: this.handleEditClick });
      menu.push({ text: intl.formatMessage(messages.delete), action: this.handleDeleteClick });
      menu.push({ text: intl.formatMessage(messages.redraft), action: this.handleRedraftClick });
    } else {
      menu.push({ text: intl.formatMessage(messages.mention, { name: status.getIn(['account', 'username']) }), action: this.handleMentionClick });
      menu.push({ text: intl.formatMessage(messages.direct, { name: status.getIn(['account', 'username']) }), action: this.handleDirectClick });
      menu.push(null);

      if (!this.props.onFilter) {
        menu.push({ text: intl.formatMessage(messages.filter), action: this.handleFilterClick });
        menu.push(null);
      }

      menu.push({ text: intl.formatMessage(messages.mute, { name: status.getIn(['account', 'username']) }), action: this.handleMuteClick });
      menu.push({ text: intl.formatMessage(messages.block, { name: status.getIn(['account', 'username']) }), action: this.handleBlockClick });
      menu.push({ text: intl.formatMessage(messages.report, { name: status.getIn(['account', 'username']) }), action: this.handleReport });

      if ((this.context.identity.permissions & PERMISSION_MANAGE_USERS) === PERMISSION_MANAGE_USERS && (accountAdminLink || statusAdminLink)) {
        menu.push(null);
        if (accountAdminLink !== undefined) {
          menu.push({
            text: intl.formatMessage(messages.admin_account, { name: status.getIn(['account', 'username']) }),
            href: accountAdminLink(status.getIn(['account', 'id'])),
          });
        }
        if (statusAdminLink !== undefined) {
          menu.push({
            text: intl.formatMessage(messages.admin_status),
            href: statusAdminLink(status.getIn(['account', 'id']), status.get('id')),
          });
        }
      }
    }

    if (status.get('in_reply_to_id', null) === null) {
      replyIcon = 'reply';
      replyTitle = intl.formatMessage(messages.reply);
    } else {
      replyIcon = 'reply-all';
      replyTitle = intl.formatMessage(messages.replyAll);
    }

    const shareButton = ('share' in navigator) && publicStatus && (
      <IconButton className='status__action-bar-button' title={intl.formatMessage(messages.share)} icon='share-alt' onClick={this.handleShareClick} />
    );

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

    const filterButton = this.props.onFilter && (
      <IconButton className='status__action-bar-button' title={intl.formatMessage(messages.hide)} icon='eye' onClick={this.handleHideClick} />
    );

    return (
      <div className='status__action-bar'>
        <IconButton
          className='status__action-bar-button'
          title={replyTitle}
          icon={replyIcon}
          onClick={this.handleReplyClick}
          counter={showReplyCount ? status.get('replies_count') : undefined}
          obfuscateCount
        />
        <IconButton className={classNames('status__action-bar-button', { reblogPrivate })} disabled={!publicStatus && !reblogPrivate} active={status.get('reblogged')} title={reblogTitle} icon={reblogIcon} onClick={this.handleReblogClick} counter={withCounters ? status.get('reblogs_count') : undefined} />
        <IconButton className='status__action-bar-button star-icon' animate active={status.get('favourited')} title={intl.formatMessage(messages.favourite)} icon='star' onClick={this.handleFavouriteClick} counter={withCounters ? status.get('favourites_count') : undefined} />
        {shareButton}
        <IconButton className='status__action-bar-button bookmark-icon' disabled={anonymousAccess} active={status.get('bookmarked')} title={intl.formatMessage(messages.bookmark)} icon='bookmark' onClick={this.handleBookmarkClick} />

        {filterButton}

        <div className='status__action-bar-dropdown'>
          <DropdownMenuContainer
            scrollKey={scrollKey}
            disabled={anonymousAccess}
            status={status}
            items={menu}
            icon='ellipsis-h'
            size={18}
            direction='right'
            ariaLabel={intl.formatMessage(messages.more)}
          />
        </div>

        <a href={status.get('url')} className='status__relative-time' target='_blank' rel='noopener'>
          <RelativeTimestamp timestamp={status.get('created_at')} />{status.get('edited_at') && <abbr title={intl.formatMessage(messages.edited, { date: intl.formatDate(status.get('edited_at'), { hour12: false, year: 'numeric', month: 'short', day: '2-digit', hour: '2-digit', minute: '2-digit' }) })}> *</abbr>}
        </a>
      </div>
    );
  }

}

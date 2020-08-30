import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import IconButton from './icon_button';
import DropdownMenuContainer from 'flavours/glitch/containers/dropdown_menu_container';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { me, isStaff } from 'flavours/glitch/util/initial_state';
import RelativeTimestamp from './relative_timestamp';
import { accountAdminLink, statusAdminLink } from 'flavours/glitch/util/backend_links';
import classNames from 'classnames';

const messages = defineMessages({
  delete: { id: 'status.delete', defaultMessage: 'Delete' },
  redraft: { id: 'status.redraft', defaultMessage: 'Delete & re-draft' },
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
});

const obfuscatedCount = count => {
  if (count < 0) {
    return 0;
  } else if (count <= 1) {
    return count;
  } else {
    return '1+';
  }
};

export default @injectIntl
class StatusActionBar extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
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
    withDismiss: PropTypes.bool,
    showReplyCount: PropTypes.bool,
    directMessage: PropTypes.bool,
    scrollKey: PropTypes.string,
    intl: PropTypes.object.isRequired,
  };

  // Avoid checking props that are functions (and whose equality will always
  // evaluate to false. See react-immutable-pure-component for usage.
  updateOnProps = [
    'status',
    'showReplyCount',
    'withDismiss',
  ]

  handleReplyClick = () => {
    if (me) {
      this.props.onReply(this.props.status, this.context.router.history);
    } else {
      this._openInteractionDialog('reply');
    }
  }

  handleShareClick = () => {
    navigator.share({
      text: this.props.status.get('search_index'),
      url: this.props.status.get('url'),
    });
  }

  handleFavouriteClick = (e) => {
    if (me) {
      this.props.onFavourite(this.props.status, e);
    } else {
      this._openInteractionDialog('favourite');
    }
  }

  handleBookmarkClick = (e) => {
    this.props.onBookmark(this.props.status, e);
  }

  handleReblogClick = e => {
    if (me) {
      this.props.onReblog(this.props.status, e);
    } else {
      this._openInteractionDialog('reblog');
    }
  }

  _openInteractionDialog = type => {
    window.open(`/interact/${this.props.status.get('id')}?type=${type}`, 'mastodon-intent', 'width=445,height=600,resizable=no,menubar=no,status=no,scrollbars=yes');
   }

  handleDeleteClick = () => {
    this.props.onDelete(this.props.status, this.context.router.history);
  }

  handleRedraftClick = () => {
    this.props.onDelete(this.props.status, this.context.router.history, true);
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
    if (state.mastodonModalOpen) {
      this.context.router.history.replace(`/statuses/${this.props.status.get('id')}`, { mastodonBackSteps: (state.mastodonBackSteps || 0) + 1 });
    } else {
      state.mastodonBackSteps = (state.mastodonBackSteps || 0) + 1;
      this.context.router.history.push(`/statuses/${this.props.status.get('id')}`, state);
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
    const url      = this.props.status.get('url');
    const textarea = document.createElement('textarea');

    textarea.textContent    = url;
    textarea.style.position = 'fixed';

    document.body.appendChild(textarea);

    try {
      textarea.select();
      document.execCommand('copy');
    } catch (e) {

    } finally {
      document.body.removeChild(textarea);
    }
  }

  handleFilterClick = () => {
    this.props.onFilter();
  }

  render () {
    const { status, intl, withDismiss, showReplyCount, directMessage, scrollKey } = this.props;

    const mutingConversation = status.get('muted');
    const anonymousAccess    = !me;
    const publicStatus       = ['public', 'unlisted'].includes(status.get('visibility'));

    let menu = [];
    let reblogIcon = 'retweet';
    let replyIcon;
    let replyTitle;

    menu.push({ text: intl.formatMessage(messages.open), action: this.handleOpen });

    if (publicStatus) {
      menu.push({ text: intl.formatMessage(messages.copy), action: this.handleCopy });
      menu.push({ text: intl.formatMessage(messages.embed), action: this.handleEmbed });
    }

    menu.push(null);

    if (status.getIn(['account', 'id']) === me || withDismiss) {
      menu.push({ text: intl.formatMessage(mutingConversation ? messages.unmuteConversation : messages.muteConversation), action: this.handleConversationMuteClick });
      menu.push(null);
    }

    if (status.getIn(['account', 'id']) === me) {
      if (publicStatus) {
        menu.push({ text: intl.formatMessage(status.get('pinned') ? messages.unpin : messages.pin), action: this.handlePinClick });
      }

      menu.push({ text: intl.formatMessage(messages.delete), action: this.handleDeleteClick });
      menu.push({ text: intl.formatMessage(messages.redraft), action: this.handleRedraftClick });
    } else {
      menu.push({ text: intl.formatMessage(messages.mention, { name: status.getIn(['account', 'username']) }), action: this.handleMentionClick });
      menu.push({ text: intl.formatMessage(messages.direct, { name: status.getIn(['account', 'username']) }), action: this.handleDirectClick });
      menu.push(null);
      menu.push({ text: intl.formatMessage(messages.mute, { name: status.getIn(['account', 'username']) }), action: this.handleMuteClick });
      menu.push({ text: intl.formatMessage(messages.block, { name: status.getIn(['account', 'username']) }), action: this.handleBlockClick });
      menu.push({ text: intl.formatMessage(messages.report, { name: status.getIn(['account', 'username']) }), action: this.handleReport });

      if (isStaff && (accountAdminLink || statusAdminLink)) {
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

    const filterButton = status.get('filtered') && (
      <IconButton className='status__action-bar-button' title={intl.formatMessage(messages.hide)} icon='eye' onClick={this.handleFilterClick} />
    );

    let replyButton = (
      <IconButton
        className='status__action-bar-button'
        title={replyTitle}
        icon={replyIcon}
        onClick={this.handleReplyClick}
      />
    );
    if (showReplyCount) {
      replyButton = (
        <div className='status__action-bar__counter'>
          {replyButton}
          <span className='status__action-bar__counter__label' >{obfuscatedCount(status.get('replies_count'))}</span>
        </div>
      );
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

    return (
      <div className='status__action-bar'>
        {replyButton}
        {!directMessage && [
          <IconButton key='reblog-button' className={classNames('status__action-bar-button', { reblogPrivate })} disabled={!publicStatus && !reblogPrivate} active={status.get('reblogged')} pressed={status.get('reblogged')} title={reblogTitle} icon={reblogIcon} onClick={this.handleReblogClick} />,
          <IconButton key='favourite-button' className='status__action-bar-button star-icon' animate active={status.get('favourited')} pressed={status.get('favourited')} title={intl.formatMessage(messages.favourite)} icon='star' onClick={this.handleFavouriteClick} />,
          shareButton,
          <IconButton key='bookmark-button' className='status__action-bar-button bookmark-icon' disabled={anonymousAccess} active={status.get('bookmarked')} pressed={status.get('bookmarked')} title={intl.formatMessage(messages.bookmark)} icon='bookmark' onClick={this.handleBookmarkClick} />,
          filterButton,
          <div key='dropdown-button' className='status__action-bar-dropdown'>
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
          </div>,
        ]}

        <a href={status.get('url')} className='status__relative-time' target='_blank' rel='noopener'><RelativeTimestamp timestamp={status.get('created_at')} /></a>
      </div>
    );
  }

}

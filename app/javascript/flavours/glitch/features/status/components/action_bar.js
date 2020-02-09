import React from 'react';
import PropTypes from 'prop-types';
import IconButton from 'flavours/glitch/components/icon_button';
import ImmutablePropTypes from 'react-immutable-proptypes';
import DropdownMenuContainer from 'flavours/glitch/containers/dropdown_menu_container';
import { defineMessages, injectIntl } from 'react-intl';
import { me, isStaff } from 'flavours/glitch/util/initial_state';
import { accountAdminLink, statusAdminLink } from 'flavours/glitch/util/backend_links';

const messages = defineMessages({
  delete: { id: 'status.delete', defaultMessage: 'Delete' },
  redraft: { id: 'status.redraft', defaultMessage: 'Delete & re-draft' },
  direct: { id: 'status.direct', defaultMessage: 'Direct message @{name}' },
  mention: { id: 'status.mention', defaultMessage: 'Mention @{name}' },
  reply: { id: 'status.reply', defaultMessage: 'Reply' },
  reblog: { id: 'status.reblog', defaultMessage: 'Boost' },
  reblog_private: { id: 'status.reblog_private', defaultMessage: 'Boost to original audience' },
  cannot_reblog: { id: 'status.cannot_reblog', defaultMessage: 'This post cannot be boosted' },
  favourite: { id: 'status.favourite', defaultMessage: 'Favourite' },
  bookmark: { id: 'status.bookmark', defaultMessage: 'Bookmark' },
  more: { id: 'status.more', defaultMessage: 'More' },
  mute: { id: 'status.mute', defaultMessage: 'Mute @{name}' },
  muteConversation: { id: 'status.mute_conversation', defaultMessage: 'Mute conversation' },
  unmuteConversation: { id: 'status.unmute_conversation', defaultMessage: 'Unmute conversation' },
  block: { id: 'status.block', defaultMessage: 'Block @{name}' },
  report: { id: 'status.report', defaultMessage: 'Report @{name}' },
  share: { id: 'status.share', defaultMessage: 'Share' },
  pin: { id: 'status.pin', defaultMessage: 'Pin on profile' },
  unpin: { id: 'status.unpin', defaultMessage: 'Unpin from profile' },
  embed: { id: 'status.embed', defaultMessage: 'Embed' },
  admin_account: { id: 'status.admin_account', defaultMessage: 'Open moderation interface for @{name}' },
  admin_status: { id: 'status.admin_status', defaultMessage: 'Open this status in the moderation interface' },
  copy: { id: 'status.copy', defaultMessage: 'Copy link to status' },
});

export default @injectIntl
class ActionBar extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    onReply: PropTypes.func.isRequired,
    onReblog: PropTypes.func.isRequired,
    onFavourite: PropTypes.func.isRequired,
    onBookmark: PropTypes.func.isRequired,
    onMute: PropTypes.func,
    onMuteConversation: PropTypes.func,
    onBlock: PropTypes.func,
    onDelete: PropTypes.func.isRequired,
    onDirect: PropTypes.func.isRequired,
    onMention: PropTypes.func.isRequired,
    onReport: PropTypes.func,
    onPin: PropTypes.func,
    onEmbed: PropTypes.func,
    intl: PropTypes.object.isRequired,
  };

  handleReplyClick = () => {
    this.props.onReply(this.props.status);
  }

  handleReblogClick = (e) => {
    this.props.onReblog(this.props.status, e);
  }

  handleFavouriteClick = (e) => {
    this.props.onFavourite(this.props.status, e);
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

  handleDirectClick = () => {
    this.props.onDirect(this.props.status.get('account'), this.context.router.history);
  }

  handleMentionClick = () => {
    this.props.onMention(this.props.status.get('account'), this.context.router.history);
  }

  handleMuteClick = () => {
    this.props.onMute(this.props.status.get('account'));
  }

  handleConversationMuteClick = () => {
    this.props.onMuteConversation(this.props.status);
  }

  handleBlockClick = () => {
    this.props.onBlock(this.props.status);
  }

  handleReport = () => {
    this.props.onReport(this.props.status);
  }

  handlePinClick = () => {
    this.props.onPin(this.props.status);
  }

  handleShare = () => {
    navigator.share({
      text: this.props.status.get('search_index'),
      url: this.props.status.get('url'),
    });
  }

  handleEmbed = () => {
    this.props.onEmbed(this.props.status);
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

  render () {
    const { status, intl } = this.props;

    const publicStatus = ['public', 'unlisted'].includes(status.get('visibility'));
    const mutingConversation = status.get('muted');

    let menu = [];

    if (publicStatus) {
      menu.push({ text: intl.formatMessage(messages.copy), action: this.handleCopy });
      menu.push({ text: intl.formatMessage(messages.embed), action: this.handleEmbed });
      menu.push(null);
    }

    if (me === status.getIn(['account', 'id'])) {
      if (publicStatus) {
        menu.push({ text: intl.formatMessage(status.get('pinned') ? messages.unpin : messages.pin), action: this.handlePinClick });
      }

      menu.push(null);
      menu.push({ text: intl.formatMessage(mutingConversation ? messages.unmuteConversation : messages.muteConversation), action: this.handleConversationMuteClick });
      menu.push(null);
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

    const shareButton = ('share' in navigator) && publicStatus && (
      <div className='detailed-status__button'><IconButton title={intl.formatMessage(messages.share)} icon='share-alt' onClick={this.handleShare} /></div>
    );

    let reblogIcon = 'retweet';
    //if (status.get('visibility') === 'direct') reblogIcon = 'envelope';
    // else if (status.get('visibility') === 'private') reblogIcon = 'lock';

    let reblog_disabled = (status.get('visibility') === 'direct' || (status.get('visibility') === 'private' && me !== status.getIn(['account', 'id'])));
    let reblog_message  = status.get('visibility') === 'private' ? messages.reblog_private : messages.reblog;

    return (
      <div className='detailed-status__action-bar'>
        <div className='detailed-status__button'><IconButton title={intl.formatMessage(messages.reply)} icon={status.get('in_reply_to_id', null) === null ? 'reply' : 'reply-all'} onClick={this.handleReplyClick} /></div>
        <div className='detailed-status__button'><IconButton disabled={reblog_disabled} active={status.get('reblogged')} title={reblog_disabled ? intl.formatMessage(messages.cannot_reblog) : intl.formatMessage(reblog_message)} icon={reblogIcon} onClick={this.handleReblogClick} /></div>
        <div className='detailed-status__button'><IconButton className='star-icon' animate active={status.get('favourited')} title={intl.formatMessage(messages.favourite)} icon='star' onClick={this.handleFavouriteClick} /></div>
        {shareButton}
        <div className='detailed-status__button'><IconButton className='bookmark-icon' active={status.get('bookmarked')} title={intl.formatMessage(messages.bookmark)} icon='bookmark' onClick={this.handleBookmarkClick} /></div>

        <div className='detailed-status__action-bar-dropdown'>
          <DropdownMenuContainer size={18} icon='ellipsis-h' items={menu} direction='left' title={intl.formatMessage(messages.more)} />
        </div>
      </div>
    );
  }

}

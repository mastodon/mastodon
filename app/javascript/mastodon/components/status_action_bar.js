import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import IconButton from './icon_button';
import DropdownMenu from './dropdown_menu';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  delete: { id: 'status.delete', defaultMessage: 'Delete' },
  mention: { id: 'status.mention', defaultMessage: 'Mention @{name}' },
  mute: { id: 'account.mute', defaultMessage: 'Mute @{name}' },
  block: { id: 'account.block', defaultMessage: 'Block @{name}' },
  reply: { id: 'status.reply', defaultMessage: 'Reply' },
  replyAll: { id: 'status.replyAll', defaultMessage: 'Reply to thread' },
  reblog: { id: 'status.reblog', defaultMessage: 'Boost' },
  cannot_reblog: { id: 'status.cannot_reblog', defaultMessage: 'This post cannot be boosted' },
  favourite: { id: 'status.favourite', defaultMessage: 'Favourite' },
  open: { id: 'status.open', defaultMessage: 'Expand this status' },
  report: { id: 'status.report', defaultMessage: 'Report @{name}' },
  muteConversation: { id: 'status.mute_conversation', defaultMessage: 'Mute conversation' },
  unmuteConversation: { id: 'status.unmute_conversation', defaultMessage: 'Unmute conversation' },
});

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
    onMention: PropTypes.func,
    onMute: PropTypes.func,
    onBlock: PropTypes.func,
    onReport: PropTypes.func,
    onMuteConversation: PropTypes.func,
    me: PropTypes.number.isRequired,
    withDismiss: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  // Avoid checking props that are functions (and whose equality will always
  // evaluate to false. See react-immutable-pure-component for usage.
  updateOnProps = [
    'status',
    'me',
    'withDismiss',
  ]

  handleReplyClick = () => {
    this.props.onReply(this.props.status, this.context.router);
  }

  handleFavouriteClick = () => {
    this.props.onFavourite(this.props.status);
  }

  handleReblogClick = (e) => {
    this.props.onReblog(this.props.status, e);
  }

  handleDeleteClick = () => {
    this.props.onDelete(this.props.status);
  }

  handleMentionClick = () => {
    this.props.onMention(this.props.status.get('account'), this.context.router);
  }

  handleMuteClick = () => {
    this.props.onMute(this.props.status.get('account'));
  }

  handleBlockClick = () => {
    this.props.onBlock(this.props.status.get('account'));
  }

  handleOpen = () => {
    this.context.router.push(`/statuses/${this.props.status.get('id')}`);
  }

  handleReport = () => {
    this.props.onReport(this.props.status);
    this.context.router.push('/report');
  }

  handleConversationMuteClick = () => {
    this.props.onMuteConversation(this.props.status);
  }

  render () {
    const { status, me, intl, withDismiss } = this.props;
    const reblogDisabled = status.get('visibility') === 'private' || status.get('visibility') === 'direct';
    const mutingConversation = status.get('muted');

    let menu = [];
    let reblogIcon = 'retweet';
    let replyIcon;
    let replyTitle;

    menu.push({ text: intl.formatMessage(messages.open), action: this.handleOpen });
    menu.push(null);

    if (withDismiss) {
      menu.push({ text: intl.formatMessage(mutingConversation ? messages.unmuteConversation : messages.muteConversation), action: this.handleConversationMuteClick });
      menu.push(null);
    }

    if (status.getIn(['account', 'id']) === me) {
      menu.push({ text: intl.formatMessage(messages.delete), action: this.handleDeleteClick });
    } else {
      menu.push({ text: intl.formatMessage(messages.mention, { name: status.getIn(['account', 'username']) }), action: this.handleMentionClick });
      menu.push(null);
      menu.push({ text: intl.formatMessage(messages.mute, { name: status.getIn(['account', 'username']) }), action: this.handleMuteClick });
      menu.push({ text: intl.formatMessage(messages.block, { name: status.getIn(['account', 'username']) }), action: this.handleBlockClick });
      menu.push({ text: intl.formatMessage(messages.report, { name: status.getIn(['account', 'username']) }), action: this.handleReport });
    }

    if (status.get('visibility') === 'direct') {
      reblogIcon = 'envelope';
    } else if (status.get('visibility') === 'private') {
      reblogIcon = 'lock';
    }

    if (status.get('in_reply_to_id', null) === null) {
      replyIcon = 'reply';
      replyTitle = intl.formatMessage(messages.reply);
    } else {
      replyIcon = 'reply-all';
      replyTitle = intl.formatMessage(messages.replyAll);
    }

    return (
      <div className='status__action-bar'>
        <IconButton className='status__action-bar-button' title={replyTitle} icon={replyIcon} onClick={this.handleReplyClick} />
        <IconButton className='status__action-bar-button' disabled={reblogDisabled} active={status.get('reblogged')} title={reblogDisabled ? intl.formatMessage(messages.cannot_reblog) : intl.formatMessage(messages.reblog)} icon={reblogIcon} onClick={this.handleReblogClick} />
        <IconButton className='status__action-bar-button star-icon' animate active={status.get('favourited')} title={intl.formatMessage(messages.favourite)} icon='star' onClick={this.handleFavouriteClick} />

        <div className='status__action-bar-dropdown'>
          <DropdownMenu items={menu} icon='ellipsis-h' size={18} direction='right' ariaLabel='More' />
        </div>
      </div>
    );
  }

}

export default injectIntl(StatusActionBar);

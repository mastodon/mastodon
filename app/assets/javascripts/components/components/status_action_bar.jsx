import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import IconButton from './icon_button';
import DropdownMenu from './dropdown_menu';
import { defineMessages, injectIntl } from 'react-intl';

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
  report: { id: 'status.report', defaultMessage: 'Report @{name}' }
});

class StatusActionBar extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.handleReplyClick = this.handleReplyClick.bind(this);
    this.handleFavouriteClick = this.handleFavouriteClick.bind(this);
    this.handleReblogClick = this.handleReblogClick.bind(this);
    this.handleDeleteClick = this.handleDeleteClick.bind(this);
    this.handleMentionClick = this.handleMentionClick.bind(this);
    this.handleMuteClick = this.handleMuteClick.bind(this);
    this.handleBlockClick = this.handleBlockClick.bind(this);
    this.handleOpen = this.handleOpen.bind(this);
    this.handleReport = this.handleReport.bind(this);
  }

  handleReplyClick () {
    this.props.onReply(this.props.status, this.context.router);
  }

  handleFavouriteClick () {
    this.props.onFavourite(this.props.status);
  }

  handleReblogClick (e) {
    this.props.onReblog(this.props.status, e);
  }

  handleDeleteClick () {
    this.props.onDelete(this.props.status);
  }

  handleMentionClick () {
    this.props.onMention(this.props.status.get('account'), this.context.router);
  }

  handleMuteClick () {
    this.props.onMute(this.props.status.get('account'));
  }

  handleBlockClick () {
    this.props.onBlock(this.props.status.get('account'));
  }

  handleOpen () {
    this.context.router.push(`/statuses/${this.props.status.get('id')}`);
  }

  handleReport () {
    this.props.onReport(this.props.status);
    this.context.router.push('/report');
  }

  render () {
    const { status, me, intl } = this.props;
    const reblog_disabled = status.get('visibility') === 'private' || status.get('visibility') === 'direct';
    let menu = [];

    menu.push({ text: intl.formatMessage(messages.open), action: this.handleOpen });
    menu.push(null);

    if (status.getIn(['account', 'id']) === me) {
      menu.push({ text: intl.formatMessage(messages.delete), action: this.handleDeleteClick });
    } else {
      menu.push({ text: intl.formatMessage(messages.mention, { name: status.getIn(['account', 'username']) }), action: this.handleMentionClick });
      menu.push(null);
      menu.push({ text: intl.formatMessage(messages.mute, { name: status.getIn(['account', 'username']) }), action: this.handleMuteClick });
      menu.push({ text: intl.formatMessage(messages.block, { name: status.getIn(['account', 'username']) }), action: this.handleBlockClick });
      menu.push({ text: intl.formatMessage(messages.report, { name: status.getIn(['account', 'username']) }), action: this.handleReport });
    }

    let reblogIcon = 'retweet';
    if (status.get('visibility') === 'direct') reblogIcon = 'envelope';
    else if (status.get('visibility') === 'private') reblogIcon = 'lock';
    let reply_icon;
    let reply_title;
    if (status.get('in_reply_to_id', null) === null) {
      reply_icon = "reply";
      reply_title = intl.formatMessage(messages.reply);
    } else {
      reply_icon = "reply-all";
      reply_title = intl.formatMessage(messages.replyAll);
    }

    return (
      <div className='status__action-bar'>
        <div className='status__action-bar-button-wrapper'><IconButton title={reply_title} icon={reply_icon} onClick={this.handleReplyClick} /></div>
        <div className='status__action-bar-button-wrapper'><IconButton disabled={reblog_disabled} active={status.get('reblogged')} title={reblog_disabled ? intl.formatMessage(messages.cannot_reblog) : intl.formatMessage(messages.reblog)} icon={reblogIcon} onClick={this.handleReblogClick} /></div>
        <div className='status__action-bar-button-wrapper'><IconButton animate={true} active={status.get('favourited')} title={intl.formatMessage(messages.favourite)} icon='star' onClick={this.handleFavouriteClick} className='star-icon' /></div>

        <div className='status__action-bar-dropdown'>
          <DropdownMenu items={menu} icon='ellipsis-h' size={18} direction="right" ariaLabel="More"/>
        </div>
      </div>
    );
  }

}

StatusActionBar.contextTypes = {
  router: PropTypes.object
};

StatusActionBar.propTypes = {
  status: ImmutablePropTypes.map.isRequired,
  onReply: PropTypes.func,
  onFavourite: PropTypes.func,
  onReblog: PropTypes.func,
  onDelete: PropTypes.func,
  onMention: PropTypes.func,
  onMute: PropTypes.func,
  onBlock: PropTypes.func,
  onReport: PropTypes.func,
  me: PropTypes.number.isRequired,
  intl: PropTypes.object.isRequired
};

export default injectIntl(StatusActionBar);

import React from 'react';
import PropTypes from 'prop-types';
import IconButton from '../../../components/icon_button';
import ImmutablePropTypes from 'react-immutable-proptypes';
import DropdownMenuContainer from '../../../containers/dropdown_menu_container';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  delete: { id: 'status.delete', defaultMessage: 'Delete' },
  mention: { id: 'status.mention', defaultMessage: 'Mention @{name}' },
  reply: { id: 'status.reply', defaultMessage: 'Reply' },
  reblog: { id: 'status.reblog', defaultMessage: 'Boost' },
  cannot_reblog: { id: 'status.cannot_reblog', defaultMessage: 'This post cannot be boosted' },
  favourite: { id: 'status.favourite', defaultMessage: 'Favourite' },
  report: { id: 'status.report', defaultMessage: 'Report @{name}' },
  share: { id: 'status.share', defaultMessage: 'Share' },
});

@injectIntl
export default class ActionBar extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    onReply: PropTypes.func.isRequired,
    onReblog: PropTypes.func.isRequired,
    onFavourite: PropTypes.func.isRequired,
    onDelete: PropTypes.func.isRequired,
    onMention: PropTypes.func.isRequired,
    onReport: PropTypes.func,
    me: PropTypes.number.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleReplyClick = () => {
    this.props.onReply(this.props.status);
  }

  handleReblogClick = (e) => {
    this.props.onReblog(this.props.status, e);
  }

  handleFavouriteClick = () => {
    this.props.onFavourite(this.props.status);
  }

  handleDeleteClick = () => {
    this.props.onDelete(this.props.status);
  }

  handleMentionClick = () => {
    this.props.onMention(this.props.status.get('account'), this.context.router.history);
  }

  handleReport = () => {
    this.props.onReport(this.props.status);
  }

  handleShare = () => {
    navigator.share({
      text: this.props.status.get('search_index'),
      url: this.props.status.get('url'),
    });
  }

  render () {
    const { status, me, intl } = this.props;

    let menu = [];

    if (me === status.getIn(['account', 'id'])) {
      menu.push({ text: intl.formatMessage(messages.delete), action: this.handleDeleteClick });
    } else {
      menu.push({ text: intl.formatMessage(messages.mention, { name: status.getIn(['account', 'username']) }), action: this.handleMentionClick });
      menu.push(null);
      menu.push({ text: intl.formatMessage(messages.report, { name: status.getIn(['account', 'username']) }), action: this.handleReport });
    }

    const shareButton = ('share' in navigator) && status.get('visibility') === 'public' && (
      <div className='detailed-status__button'><IconButton title={intl.formatMessage(messages.share)} icon='share-alt' onClick={this.handleShare} /></div>
    );

    let reblogIcon = 'retweet';
    if (status.get('visibility') === 'direct') reblogIcon = 'envelope';
    else if (status.get('visibility') === 'private') reblogIcon = 'lock';

    let reblog_disabled = (status.get('visibility') === 'direct' || status.get('visibility') === 'private');

    return (
      <div className='detailed-status__action-bar'>
        <div className='detailed-status__button'><IconButton title={intl.formatMessage(messages.reply)} icon={status.get('in_reply_to_id', null) === null ? 'reply' : 'reply-all'} onClick={this.handleReplyClick} /></div>
        <div className='detailed-status__button'><IconButton disabled={reblog_disabled} active={status.get('reblogged')} title={reblog_disabled ? intl.formatMessage(messages.cannot_reblog) : intl.formatMessage(messages.reblog)} icon={reblogIcon} onClick={this.handleReblogClick} /></div>
        <div className='detailed-status__button'><IconButton animate active={status.get('favourited')} title={intl.formatMessage(messages.favourite)} icon='star' onClick={this.handleFavouriteClick} activeStyle={{ color: '#ca8f04' }} /></div>
        {shareButton}

        <div className='detailed-status__action-bar-dropdown'>
          <DropdownMenuContainer size={18} icon='ellipsis-h' items={menu} direction='left' ariaLabel='More' />
        </div>
      </div>
    );
  }

}

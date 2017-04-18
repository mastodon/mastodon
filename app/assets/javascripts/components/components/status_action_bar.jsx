import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import IconButton from './icon_button';
import DropdownMenu from './dropdown_menu';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  delete: { id: 'status.delete', defaultMessage: 'Delete' },
  mention: { id: 'status.mention', defaultMessage: 'Mention @{name}' },
  mute: { id: 'account.mute', defaultMessage: 'Mute @{name}' },
  block: { id: 'account.block', defaultMessage: 'Block @{name}' },
  reply: { id: 'status.reply', defaultMessage: 'Reply' },
  reblog: { id: 'status.reblog', defaultMessage: 'Reblog' },
  favourite: { id: 'status.favourite', defaultMessage: 'Favourite' },
  open: { id: 'status.open', defaultMessage: 'Expand this status' },
  report: { id: 'status.report', defaultMessage: 'Report @{name}' }
});

const StatusActionBar = React.createClass({

  contextTypes: {
    router: React.PropTypes.object
  },

  propTypes: {
    status: ImmutablePropTypes.map.isRequired,
    onReply: React.PropTypes.func,
    onFavourite: React.PropTypes.func,
    onReblog: React.PropTypes.func,
    onDelete: React.PropTypes.func,
    onMention: React.PropTypes.func,
    onMute: React.PropTypes.func,
    onBlock: React.PropTypes.func,
    onReport: React.PropTypes.func,
    me: React.PropTypes.number.isRequired,
    intl: React.PropTypes.object.isRequired
  },

  mixins: [PureRenderMixin],

  handleReplyClick () {
    this.props.onReply(this.props.status, this.context.router);
  },

  handleFavouriteClick () {
    this.props.onFavourite(this.props.status);
  },

  handleReblogClick (e) {
    this.props.onReblog(this.props.status, e);
  },

  handleDeleteClick () {
    this.props.onDelete(this.props.status);
  },

  handleMentionClick () {
    this.props.onMention(this.props.status.get('account'), this.context.router);
  },

  handleMuteClick () {
    this.props.onMute(this.props.status.get('account'));
  },

  handleBlockClick () {
    this.props.onBlock(this.props.status.get('account'));
  },

  handleOpen () {
    this.context.router.push(`/statuses/${this.props.status.get('id')}`);
  },

  handleReport () {
    this.props.onReport(this.props.status);
    this.context.router.push('/report');
  },

  render () {
    const { status, me, intl } = this.props;
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

    return (
      <div style={{ marginTop: '10px', overflow: 'hidden' }}>
        <div style={{ float: 'left', marginRight: '18px'}}><IconButton title={intl.formatMessage(messages.reply)} icon={status.get('in_reply_to_id', null) === null ? 'reply' : 'reply-all'} onClick={this.handleReplyClick} /></div>
        <div style={{ float: 'left', marginRight: '18px'}}><IconButton disabled={status.get('visibility') === 'private' || status.get('visibility') === 'direct'} active={status.get('reblogged')} title={intl.formatMessage(messages.reblog)} icon={reblogIcon} onClick={this.handleReblogClick} /></div>
        <div style={{ float: 'left', marginRight: '18px'}}><IconButton animate={true} active={status.get('favourited')} title={intl.formatMessage(messages.favourite)} icon='star' onClick={this.handleFavouriteClick} activeStyle={{ color: '#ca8f04' }} /></div>

        <div style={{ width: '18px', height: '18px', float: 'left' }}>
          <DropdownMenu items={menu} icon='ellipsis-h' size={18} direction="right" />
        </div>
      </div>
    );
  }

});

export default injectIntl(StatusActionBar);

import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import IconButton from './icon_button';
import DropdownMenu from './dropdown_menu';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  delete: { id: 'status.delete', defaultMessage: 'Delete' },
  mention: { id: 'status.mention', defaultMessage: 'Mention' },
  block: { id: 'account.block', defaultMessage: 'Block' },
  reply: { id: 'status.reply', defaultMessage: 'Reply' },
  reblog: { id: 'status.reblog', defaultMessage: 'Reblog' },
  favourite: { id: 'status.favourite', defaultMessage: 'Favourite' },
  open: { id: 'status.open', defaultMessage: 'Expand' }
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
    onBlock: React.PropTypes.func
  },

  mixins: [PureRenderMixin],

  handleReplyClick () {
    this.props.onReply(this.props.status, this.context.router);
  },

  handleFavouriteClick () {
    this.props.onFavourite(this.props.status);
  },

  handleReblogClick () {
    this.props.onReblog(this.props.status);
  },

  handleDeleteClick () {
    this.props.onDelete(this.props.status);
  },

  handleMentionClick () {
    this.props.onMention(this.props.status.get('account'));
  },

  handleBlockClick () {
    this.props.onBlock(this.props.status.get('account'));
  },

  handleOpen () {
    this.context.router.push(`/statuses/${this.props.status.get('id')}`);
  },

  render () {
    const { status, me, intl } = this.props;
    let menu = [];

    menu.push({ text: intl.formatMessage(messages.open), action: this.handleOpen });

    if (status.getIn(['account', 'id']) === me) {
      menu.push({ text: intl.formatMessage(messages.delete), action: this.handleDeleteClick });
    } else {
      menu.push({ text: intl.formatMessage(messages.mention), action: this.handleMentionClick });
      menu.push({ text: intl.formatMessage(messages.block), action: this.handleBlockClick });
    }

    return (
      <div style={{ marginTop: '10px', overflow: 'hidden' }}>
        <div style={{ float: 'left', marginRight: '18px'}}><IconButton title={intl.formatMessage(messages.reply)} icon='reply' onClick={this.handleReplyClick} /></div>
        <div style={{ float: 'left', marginRight: '18px'}}><IconButton active={status.get('reblogged')} title={intl.formatMessage(messages.reblog)} icon='retweet' onClick={this.handleReblogClick} /></div>
        <div style={{ float: 'left', marginRight: '18px'}}><IconButton active={status.get('favourited')} title={intl.formatMessage(messages.favourite)} icon='star' onClick={this.handleFavouriteClick} activeStyle={{ color: '#ca8f04' }} /></div>

        <div style={{ width: '18px', height: '18px', float: 'left' }}>
          <DropdownMenu items={menu} icon='ellipsis-h' size={18} />
        </div>
      </div>
    );
  }

});

export default injectIntl(StatusActionBar);

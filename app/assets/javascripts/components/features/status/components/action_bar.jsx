import PureRenderMixin from 'react-addons-pure-render-mixin';
import IconButton from '../../../components/icon_button';
import ImmutablePropTypes from 'react-immutable-proptypes';
import DropdownMenu from '../../../components/dropdown_menu';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  delete: { id: 'status.delete', defaultMessage: 'Delete' },
  mention: { id: 'status.mention', defaultMessage: 'Mention @{name}' },
  reply: { id: 'status.reply', defaultMessage: 'Reply' },
  reblog: { id: 'status.reblog', defaultMessage: 'Reblog' },
  favourite: { id: 'status.favourite', defaultMessage: 'Favourite' },
  report: { id: 'status.report', defaultMessage: 'Report @{name}' }
});

const ActionBar = React.createClass({

  contextTypes: {
    router: React.PropTypes.object
  },

  propTypes: {
    status: ImmutablePropTypes.map.isRequired,
    onReply: React.PropTypes.func.isRequired,
    onReblog: React.PropTypes.func.isRequired,
    onFavourite: React.PropTypes.func.isRequired,
    onDelete: React.PropTypes.func.isRequired,
    onMention: React.PropTypes.func.isRequired,
    onReport: React.PropTypes.func,
    me: React.PropTypes.number.isRequired,
    intl: React.PropTypes.object.isRequired
  },

  mixins: [PureRenderMixin],

  handleReplyClick () {
    this.props.onReply(this.props.status);
  },

  handleReblogClick (e) {
    this.props.onReblog(this.props.status, e);
  },

  handleFavouriteClick () {
    this.props.onFavourite(this.props.status);
  },

  handleDeleteClick () {
    this.props.onDelete(this.props.status);
  },

  handleMentionClick () {
    this.props.onMention(this.props.status.get('account'), this.context.router);
  },

  handleReport () {
    this.props.onReport(this.props.status);
    this.context.router.push('/report');
  },

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

    return (
      <div className='detailed-status__action-bar'>
        <div style={{ flex: '1 1 auto', textAlign: 'center' }}><IconButton title={intl.formatMessage(messages.reply)} icon='reply' onClick={this.handleReplyClick} /></div>
        <div style={{ flex: '1 1 auto', textAlign: 'center' }}><IconButton disabled={status.get('visibility') === 'direct' || status.get('visibility') === 'private'} active={status.get('reblogged')} title={intl.formatMessage(messages.reblog)} icon={status.get('visibility') === 'direct' ? 'envelope' : (status.get('visibility') === 'private' ? 'lock' : 'retweet')} onClick={this.handleReblogClick} /></div>
        <div style={{ flex: '1 1 auto', textAlign: 'center' }}><IconButton animate={true} active={status.get('favourited')} title={intl.formatMessage(messages.favourite)} icon='star' onClick={this.handleFavouriteClick} activeStyle={{ color: '#ca8f04' }} /></div>
        <div style={{ flex: '1 1 auto', textAlign: 'center' }}><DropdownMenu size={18} icon='ellipsis-h' items={menu} direction="left" /></div>
      </div>
    );
  }

});

export default injectIntl(ActionBar);

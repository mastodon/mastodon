import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin    from 'react-addons-pure-render-mixin';
import IconButton         from './icon_button';
import DropdownMenu       from './dropdown_menu';

const StatusActionBar = React.createClass({
  propTypes: {
    status: ImmutablePropTypes.map.isRequired,
    onReply: React.PropTypes.func,
    onFavourite: React.PropTypes.func,
    onReblog: React.PropTypes.func,
    onDelete: React.PropTypes.func,
    onMention: React.PropTypes.func
  },

  mixins: [PureRenderMixin],

  handleReplyClick () {
    this.props.onReply(this.props.status);
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

  render () {
    const { status, me } = this.props;
    let menu = [];

    if (status.getIn(['account', 'id']) === me) {
      menu.push({ text: 'Delete', action: this.handleDeleteClick });
    } else {
      menu.push({ text: 'Mention', action: this.handleMentionClick });
    }

    return (
      <div style={{ marginTop: '10px', overflow: 'hidden' }}>
        <div style={{ float: 'left', marginRight: '18px'}}><IconButton title='Reply' icon='reply' onClick={this.handleReplyClick} /></div>
        <div style={{ float: 'left', marginRight: '18px'}}><IconButton active={status.get('reblogged')} title='Reblog' icon='retweet' onClick={this.handleReblogClick} /></div>
        <div style={{ float: 'left', marginRight: '18px'}}><IconButton active={status.get('favourited')} title='Favourite' icon='star' onClick={this.handleFavouriteClick} activeStyle={{ color: '#ca8f04' }} /></div>

        <div style={{ width: '18px', height: '18px', float: 'left' }}>
          <DropdownMenu items={menu} icon='ellipsis-h' size={18} />
        </div>
      </div>
    );
  }

});

export default StatusActionBar;

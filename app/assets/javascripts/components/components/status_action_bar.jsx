import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin    from 'react-addons-pure-render-mixin';
import IconButton         from './icon_button';
import Dropdown, { DropdownTrigger, DropdownContent } from 'react-simple-dropdown';

const StatusActionBar = React.createClass({
  propTypes: {
    status: ImmutablePropTypes.map.isRequired,
    onReply: React.PropTypes.func,
    onFavourite: React.PropTypes.func,
    onReblog: React.PropTypes.func,
    onDelete: React.PropTypes.func
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

  handleDeleteClick(e) {
    e.preventDefault();
    this.props.onDelete(this.props.status);
  },

  render () {
    const { status, me } = this.props;
    let menu = '';

    if (status.getIn(['account', 'id']) === me) {
      menu = (
        <ul>
          <li><a href='#' onClick={this.handleDeleteClick}>Delete</a></li>
        </ul>
      );
    }

    return (
      <div style={{ marginTop: '10px', overflow: 'hidden' }}>
        <div style={{ float: 'left', marginRight: '18px'}}><IconButton title='Reply' icon='reply' onClick={this.handleReplyClick} /></div>
        <div style={{ float: 'left', marginRight: '18px'}}><IconButton active={status.get('reblogged')} title='Reblog' icon='retweet' onClick={this.handleReblogClick} /></div>
        <div style={{ float: 'left', marginRight: '18px'}}><IconButton active={status.get('favourited')} title='Favourite' icon='star' onClick={this.handleFavouriteClick} /></div>

        <div onClick={e => e.stopPropagation()} style={{ width: '18px', height: '18px', float: 'left' }}>
          <Dropdown>
            <DropdownTrigger className='icon-button' style={{ fontSize: '18px', lineHeight: '18px', width: '18px', height: '18px' }}>
              <i className='fa fa-fw fa-ellipsis-h' />
            </DropdownTrigger>

            <DropdownContent>{menu}</DropdownContent>
          </Dropdown>
        </div>
      </div>
    );
  }

});

export default StatusActionBar;

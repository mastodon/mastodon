import ImmutablePropTypes from 'react-immutable-proptypes';
import Avatar             from './avatar';
import RelativeTimestamp  from './relative_timestamp';
import PureRenderMixin    from 'react-addons-pure-render-mixin';
import IconButton         from './icon_button';

const Status = React.createClass({

  propTypes: {
    status: ImmutablePropTypes.map.isRequired,
    onReply: React.PropTypes.func,
    onFavourite: React.PropTypes.func,
    onReblog: React.PropTypes.func
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

  render () {
    var content = { __html: this.props.status.get('content') };
    var status  = this.props.status;

    return (
      <div style={{ padding: '8px 10px', paddingLeft: '68px', position: 'relative', minHeight: '48px', borderBottom: '1px solid #363c4b', cursor: 'pointer' }}>
        <div style={{ fontSize: '15px' }}>
          <div style={{ float: 'right', fontSize: '14px' }}>
            <a href={status.get('url')} className='status__relative-time' style={{ color: '#616b86' }}><RelativeTimestamp timestamp={status.get('created_at')} /></a>
          </div>

          <a href={status.getIn(['account', 'url'])} className='status__display-name' style={{ display: 'block', maxWidth: '100%', paddingRight: '25px', color: '#616b86' }}>
            <div style={{ position: 'absolute', left: '10px', top: '10px', width: '48px', height: '48px' }}>
              <Avatar src={status.getIn(['account', 'avatar'])} size={48} />
            </div>

            <span style={{ display: 'block', maxWidth: '100%', overflow: 'hidden', whiteSpace: 'nowrap', textOverflow: 'ellipsis' }}>
              <strong style={{ fontWeight: 'bold', color: '#fff' }}>{status.getIn(['account', 'display_name'])}</strong> <span style={{ fontSize: '14px' }}>@{status.getIn(['account', 'acct'])}</span>
            </span>
          </a>
        </div>

        <div className='status__content' dangerouslySetInnerHTML={content} />

        <div style={{ marginTop: '10px', overflow: 'hidden' }}>
          <div style={{ float: 'left', marginRight: '10px'}}><IconButton title='Reply' icon='reply' onClick={this.handleReplyClick} /></div>
          <div style={{ float: 'left', marginRight: '10px'}}><IconButton active={status.get('reblogged')} title='Reblog' icon='retweet' onClick={this.handleReblogClick} /></div>
          <div style={{ float: 'left'}}><IconButton active={status.get('favourited')} title='Favourite' icon='star' onClick={this.handleFavouriteClick} /></div>
        </div>
      </div>
    );
  }

});

export default Status;

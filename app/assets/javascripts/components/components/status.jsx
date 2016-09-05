import ImmutablePropTypes from 'react-immutable-proptypes';
import Avatar             from './avatar';
import RelativeTimestamp  from './relative_timestamp';
import PureRenderMixin    from 'react-addons-pure-render-mixin';
import IconButton         from './icon_button';
import DisplayName        from './display_name';
import MediaGallery       from './media_gallery';

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
    var media   = '';

    var { status, ...other } = this.props;

    if (status.get('reblog') !== null) {
      return (
        <div style={{ cursor: 'pointer' }}>
          <div style={{ marginLeft: '68px', color: '#616b86', padding: '8px 0', paddingBottom: '2px', fontSize: '14px', position: 'relative' }}>
            <div style={{ position: 'absolute', 'left': '-26px'}}><i className='fa fa-fw fa-retweet'></i></div>
            <a href={status.getIn(['account', 'url'])} className='status__display-name'><strong style={{ color: '#616b86'}}>{status.getIn(['account', 'display_name'])}</strong></a> reblogged
          </div>

          <Status {...other} status={status.get('reblog')} />
        </div>
      );
    }

    if (status.get('media_attachments').size > 0) {
      media = <MediaGallery media={status.get('media_attachments')} />;
    }

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

            <DisplayName account={status.get('account')} />
          </a>
        </div>

        <div className='status__content' dangerouslySetInnerHTML={content} />

        {media}

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

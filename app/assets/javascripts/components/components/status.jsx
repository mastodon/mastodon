import ImmutablePropTypes from 'react-immutable-proptypes';
import Avatar             from './avatar';
import DisplayName        from './display_name';
import RelativeTimestamp  from './relative_timestamp';

const Status = React.createClass({
  propTypes: {
    status: ImmutablePropTypes.map.isRequired
  },

  render () {
    var content = { __html: this.props.status.get('content') };
    var status  = this.props.status;

    return (
      <div style={{ padding: '8px 10px', display: 'flex', flexDirection: 'row', borderBottom: '1px solid #363c4b' }}>
        <Avatar src={status.getIn(['account', 'avatar'])} />

        <div style={{ flex: '1 1 auto', marginLeft: '10px' }}>
          <div style={{ overflow: 'hidden' }}>
            <div style={{ float: 'right' }}>
              <a href={status.get('url')} style={{ textDecoration: 'none' }}><RelativeTimestamp timestamp={status.get('created_at')} /></a>
            </div>

            <DisplayName account={status.get('account')} />
          </div>

          <div className='status__content' dangerouslySetInnerHTML={content} style={{ fontSize: '14px' }} />
        </div>
      </div>
    );
  }
});

export default Status;

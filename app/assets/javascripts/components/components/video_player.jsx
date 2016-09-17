import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin    from 'react-addons-pure-render-mixin';

const VideoPlayer = React.createClass({
  propTypes: {
    media: ImmutablePropTypes.map.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    return (
      <div style={{ cursor: 'default', marginTop: '8px', overflow: 'hidden', width: '196px', height: '110px', boxSizing: 'border-box', background: '#000' }}>
        <video src={this.props.media.get('url')} autoPlay='true' loop={true} muted={true} style={{ width: '100%', height: '100%' }} />
      </div>
    );
  }

});

export default VideoPlayer;

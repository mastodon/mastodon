import PureRenderMixin from 'react-addons-pure-render-mixin';

const ExtendedVideoPlayer = React.createClass({

  propTypes: {
    src: React.PropTypes.string.isRequired,
    time: React.PropTypes.number,
    controls: React.PropTypes.bool.isRequired,
    muted: React.PropTypes.bool.isRequired
  },

  mixins: [PureRenderMixin],

  handleLoadedData () {
    if (this.props.time) {
      this.video.currentTime = this.props.time;
    }
  },

  componentDidMount () {
    this.video.addEventListener('loadeddata', this.handleLoadedData);
  },

  componentWillUnmount () {
    this.video.removeEventListener('loadeddata', this.handleLoadedData);
  },

  setRef (c) {
    this.video = c;
  },

  render () {
    return (
      <div className='extended-video-player'>
        <video
          ref={this.setRef}
          src={this.props.src}
          autoPlay
          muted={this.props.muted}
          controls={this.props.controls}
          loop={!this.props.controls}
        />
      </div>
    );
  },

});

export default ExtendedVideoPlayer;

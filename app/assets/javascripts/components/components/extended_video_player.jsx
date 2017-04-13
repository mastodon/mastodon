import PureRenderMixin from 'react-addons-pure-render-mixin';

const ExtendedVideoPlayer = React.createClass({

  propTypes: {
    src: React.PropTypes.string.isRequired,
    controls: React.PropTypes.bool.isRequired,
    muted: React.PropTypes.bool.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    return (
      <div>
        <video src={this.props.src} autoPlay muted={this.props.muted} controls={this.props.controls} loop />
      </div>
    );
  },

});

export default ExtendedVideoPlayer;

import PureRenderMixin from 'react-addons-pure-render-mixin';

const ExtendedVideoPlayer = React.createClass({

  propTypes: {
    src: React.PropTypes.string.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    return (
      <div>
        <video src={this.props.src} autoPlay muted loop />
      </div>
    );
  },

});

export default ExtendedVideoPlayer;

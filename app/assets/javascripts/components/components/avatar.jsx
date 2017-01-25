import PureRenderMixin from 'react-addons-pure-render-mixin';

const Avatar = React.createClass({

  propTypes: {
    src: React.PropTypes.string.isRequired,
    size: React.PropTypes.number.isRequired,
    style: React.PropTypes.object
  },

  getInitialState () {
    return {
      hovering: false
    };
  },

  mixins: [PureRenderMixin],

  handleMouseEnter () {
    this.setState({ hovering: true });
  },

  handleMouseLeave () {
    this.setState({ hovering: false });
  },

  handleLoad () {
    this.canvas.getContext('2d').drawImage(this.image, 0, 0, this.props.size, this.props.size);
  },

  setImageRef (c) {
    this.image = c;
  },

  setCanvasRef (c) {
    this.canvas = c;
  },

  render () {
    const { hovering } = this.state;

    return (
      <div onMouseEnter={this.handleMouseEnter} onMouseLeave={this.handleMouseLeave} style={{ ...this.props.style, width: `${this.props.size}px`, height: `${this.props.size}px`, position: 'relative' }}>
        <img ref={this.setImageRef} onLoad={this.handleLoad} src={this.props.src} width={this.props.size} height={this.props.size} alt='' style={{ position: 'absolute', top: '0', left: '0', visibility: hovering ? 'visible' : 'hidden', borderRadius: '4px' }} />
        <canvas ref={this.setCanvasRef} width={this.props.size} height={this.props.size} style={{ borderRadius: '4px' }} />
      </div>
    );
  }

});

export default Avatar;

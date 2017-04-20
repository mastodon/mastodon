import PureRenderMixin from 'react-addons-pure-render-mixin';

const Avatar = React.createClass({

  propTypes: {
    src: React.PropTypes.string.isRequired,
    staticSrc: React.PropTypes.string,
    size: React.PropTypes.number.isRequired,
    style: React.PropTypes.object,
    animate: React.PropTypes.bool
  },

  getDefaultProps () {
    return {
      animate: false
    };
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

  render () {
    const { src, size, staticSrc, animate } = this.props;
    const { hovering } = this.state;

    const style = {
      ...this.props.style,
      width: `${size}px`,
      height: `${size}px`,
      backgroundSize: `${size}px ${size}px`
    };

    if (hovering || animate) {
      style.backgroundImage = `url(${src})`;
    } else {
      style.backgroundImage = `url(${staticSrc})`;
    }

    return (
      <div
        className='avatar'
        onMouseEnter={this.handleMouseEnter}
        onMouseLeave={this.handleMouseLeave}
        style={style}
      />
    );
  }

});

export default Avatar;

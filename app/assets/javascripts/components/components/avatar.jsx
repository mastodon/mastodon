import PropTypes from 'prop-types';

class Avatar extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.state = {
      hovering: false
    };
    this.handleMouseEnter = this.handleMouseEnter.bind(this);
    this.handleMouseLeave = this.handleMouseLeave.bind(this);
  }

  handleMouseEnter () {
    this.setState({ hovering: true });
  }

  handleMouseLeave () {
    this.setState({ hovering: false });
  }

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
        className='account__avatar'
        onMouseEnter={this.handleMouseEnter}
        onMouseLeave={this.handleMouseLeave}
        style={style}
      />
    );
  }

}

Avatar.propTypes = {
  src: PropTypes.string.isRequired,
  staticSrc: PropTypes.string,
  size: PropTypes.number.isRequired,
  style: PropTypes.object,
  animate: PropTypes.bool
};

Avatar.defaultProps = {
  animate: false
};

export default Avatar;

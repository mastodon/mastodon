import React from 'react';
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
    if (this.props.animate) return;
    this.setState({ hovering: true });
  }

  handleMouseLeave () {
    if (this.props.animate) return;
    this.setState({ hovering: false });
  }

  render () {
    const { src, size, staticSrc, animate, inline } = this.props;
    const { hovering } = this.state;

    let className = 'account__avatar';

    if (inline) {
      className = className + ' account__avatar-inline';
    }

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
        className={className}
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
  animate: PropTypes.bool,
  inline: PropTypes.bool
};

Avatar.defaultProps = {
  animate: false,
  size: 20,
  inline: false
};

export default Avatar;

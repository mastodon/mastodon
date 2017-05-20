import React from 'react';
import PropTypes from 'prop-types';

class Button extends React.PureComponent {

  static propTypes = {
    text: PropTypes.node,
    onClick: PropTypes.func,
    disabled: PropTypes.bool,
    block: PropTypes.bool,
    secondary: PropTypes.bool,
    size: PropTypes.number,
    style: PropTypes.object,
    children: PropTypes.node,
  };

  static defaultProps = {
    size: 36,
  };

  handleClick = (e) => {
    if (!this.props.disabled) {
      this.props.onClick();
    }
  }

  render () {
    const style = {
      padding: `0 ${this.props.size / 2.25}px`,
      height: `${this.props.size}px`,
      lineHeight: `${this.props.size}px`,
      ...this.props.style,
    };

    return (
      <button
        className={`button ${this.props.secondary ? 'button-secondary' : ''} ${this.props.block ? 'button--block' : ''}`}
        disabled={this.props.disabled}
        onClick={this.handleClick}
        style={style}
      >
        {this.props.text || this.props.children}
      </button>
    );
  }

}

export default Button;

import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';

export default class Button extends React.PureComponent {

  static propTypes = {
    text: PropTypes.node,
    type: PropTypes.string,
    onClick: PropTypes.func,
    disabled: PropTypes.bool,
    block: PropTypes.bool,
    secondary: PropTypes.bool,
    className: PropTypes.string,
    title: PropTypes.string,
    children: PropTypes.node,
  };

  static defaultProps = {
    type: 'button',
  };

  handleClick = (e) => {
    if (!this.props.disabled && this.props.onClick) {
      this.props.onClick(e);
    }
  };

  setRef = (c) => {
    this.node = c;
  };

  focus() {
    this.node.focus();
  }

  render () {
    const className = classNames('button', this.props.className, {
      'button-secondary': this.props.secondary,
      'button--block': this.props.block,
    });

    return (
      <button
        className={className}
        disabled={this.props.disabled}
        onClick={this.handleClick}
        ref={this.setRef}
        title={this.props.title}
        type={this.props.type}
      >
        {this.props.text || this.props.children}
      </button>
    );
  }

}

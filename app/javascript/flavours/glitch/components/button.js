import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';

export default class Button extends React.PureComponent {

  static propTypes = {
    text: PropTypes.node,
    onClick: PropTypes.func,
    disabled: PropTypes.bool,
    block: PropTypes.bool,
    secondary: PropTypes.bool,
    size: PropTypes.number,
    className: PropTypes.string,
    title: PropTypes.string,
    style: PropTypes.object,
    children: PropTypes.node,
  };

  static defaultProps = {
    size: 36,
  };

  handleClick = (e) => {
    if (!this.props.disabled) {
      this.props.onClick(e);
    }
  }

  setRef = (c) => {
    this.node = c;
  }

  focus() {
    this.node.focus();
  }

  render () {
    let attrs = {
      className: classNames('button', this.props.className, {
        'button-secondary': this.props.secondary,
        'button--block': this.props.block,
      }),
      disabled: this.props.disabled,
      onClick: this.handleClick,
      ref: this.setRef,
      style: {
        padding: `0 ${this.props.size / 2.25}px`,
        height: `${this.props.size}px`,
        lineHeight: `${this.props.size}px`,
        ...this.props.style,
      },
    };

    if (this.props.title) attrs.title = this.props.title;

    return (
      <button {...attrs}>
        {this.props.text || this.props.children}
      </button>
    );
  }

}

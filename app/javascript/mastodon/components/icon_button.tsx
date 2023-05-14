import React from 'react';
import classNames from 'classnames';
import { Icon } from './icon';
import { AnimatedNumber } from './animated_number';

type Props = {
  className?: string;
  title: string;
  icon: string;
  onClick?: React.MouseEventHandler<HTMLButtonElement>;
  onMouseDown?: React.MouseEventHandler<HTMLButtonElement>;
  onKeyDown?: React.KeyboardEventHandler<HTMLButtonElement>;
  onKeyPress?: React.KeyboardEventHandler<HTMLButtonElement>;
  size: number;
  active: boolean;
  expanded?: boolean;
  style?: React.CSSProperties;
  activeStyle?: React.CSSProperties;
  disabled: boolean;
  inverted?: boolean;
  animate: boolean;
  overlay: boolean;
  tabIndex: number;
  counter?: number;
  obfuscateCount?: boolean;
  href?: string;
  ariaHidden: boolean;
};
type States = {
  activate: boolean;
  deactivate: boolean;
};
export class IconButton extends React.PureComponent<Props, States> {
  static defaultProps = {
    size: 18,
    active: false,
    disabled: false,
    animate: false,
    overlay: false,
    tabIndex: 0,
    ariaHidden: false,
  };

  state = {
    activate: false,
    deactivate: false,
  };

  UNSAFE_componentWillReceiveProps(nextProps: Props) {
    if (!nextProps.animate) return;

    if (this.props.active && !nextProps.active) {
      this.setState({ activate: false, deactivate: true });
    } else if (!this.props.active && nextProps.active) {
      this.setState({ activate: true, deactivate: false });
    }
  }

  handleClick: React.MouseEventHandler<HTMLButtonElement> = (e) => {
    e.preventDefault();

    if (!this.props.disabled && this.props.onClick != null) {
      this.props.onClick(e);
    }
  };

  handleKeyPress: React.KeyboardEventHandler<HTMLButtonElement> = (e) => {
    if (this.props.onKeyPress && !this.props.disabled) {
      this.props.onKeyPress(e);
    }
  };

  handleMouseDown: React.MouseEventHandler<HTMLButtonElement> = (e) => {
    if (!this.props.disabled && this.props.onMouseDown) {
      this.props.onMouseDown(e);
    }
  };

  handleKeyDown: React.KeyboardEventHandler<HTMLButtonElement> = (e) => {
    if (!this.props.disabled && this.props.onKeyDown) {
      this.props.onKeyDown(e);
    }
  };

  render() {
    const style = {
      fontSize: `${this.props.size}px`,
      width: `${this.props.size * 1.28571429}px`,
      height: `${this.props.size * 1.28571429}px`,
      lineHeight: `${this.props.size}px`,
      ...this.props.style,
      ...(this.props.active ? this.props.activeStyle : {}),
    };

    const {
      active,
      className,
      disabled,
      expanded,
      icon,
      inverted,
      overlay,
      tabIndex,
      title,
      counter,
      obfuscateCount,
      href,
      ariaHidden,
    } = this.props;

    const { activate, deactivate } = this.state;

    const classes = classNames(className, 'icon-button', {
      active,
      disabled,
      inverted,
      activate,
      deactivate,
      overlayed: overlay,
      'icon-button--with-counter': typeof counter !== 'undefined',
    });

    if (typeof counter !== 'undefined') {
      style.width = 'auto';
    }

    let contents = (
      <React.Fragment>
        <Icon id={icon} fixedWidth aria-hidden='true' />{' '}
        {typeof counter !== 'undefined' && (
          <span className='icon-button__counter'>
            <AnimatedNumber value={counter} obfuscate={obfuscateCount} />
          </span>
        )}
      </React.Fragment>
    );

    if (href != null) {
      contents = (
        <a href={href} target='_blank' rel='noopener noreferrer'>
          {contents}
        </a>
      );
    }

    return (
      <button
        type='button'
        aria-label={title}
        aria-expanded={expanded}
        aria-hidden={ariaHidden}
        title={title}
        className={classes}
        onClick={this.handleClick}
        onMouseDown={this.handleMouseDown}
        onKeyDown={this.handleKeyDown}
        onKeyPress={this.handleKeyPress}
        style={style}
        tabIndex={tabIndex}
        disabled={disabled}
      >
        {contents}
      </button>
    );
  }
}

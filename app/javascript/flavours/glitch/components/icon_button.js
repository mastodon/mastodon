import React from 'react';
import Motion from 'flavours/glitch/util/optional_motion';
import spring from 'react-motion/lib/spring';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import Icon from 'flavours/glitch/components/icon';

export default class IconButton extends React.PureComponent {

  static propTypes = {
    className: PropTypes.string,
    title: PropTypes.string.isRequired,
    icon: PropTypes.string.isRequired,
    onClick: PropTypes.func,
    onMouseDown: PropTypes.func,
    onKeyDown: PropTypes.func,
    onKeyPress: PropTypes.func,
    size: PropTypes.number,
    active: PropTypes.bool,
    pressed: PropTypes.bool,
    expanded: PropTypes.bool,
    style: PropTypes.object,
    activeStyle: PropTypes.object,
    disabled: PropTypes.bool,
    inverted: PropTypes.bool,
    animate: PropTypes.bool,
    flip: PropTypes.bool,
    overlay: PropTypes.bool,
    tabIndex: PropTypes.string,
    label: PropTypes.string,
  };

  static defaultProps = {
    size: 18,
    active: false,
    disabled: false,
    animate: false,
    overlay: false,
    tabIndex: '0',
  };

  handleClick = (e) =>  {
    e.preventDefault();

    if (!this.props.disabled) {
      this.props.onClick(e);
    }
  }

  handleKeyPress = (e) => {
    if (this.props.onKeyPress && !this.props.disabled) {
      this.props.onKeyPress(e);
    }
  }

  handleMouseDown = (e) => {
    if (!this.props.disabled && this.props.onMouseDown) {
      this.props.onMouseDown(e);
    }
  }

  handleKeyDown = (e) => {
    if (!this.props.disabled && this.props.onKeyDown) {
      this.props.onKeyDown(e);
    }
  }

  render () {
    let style = {
      fontSize: `${this.props.size}px`,
      height: `${this.props.size * 1.28571429}px`,
      lineHeight: `${this.props.size}px`,
      ...this.props.style,
      ...(this.props.active ? this.props.activeStyle : {}),
    };
    if (!this.props.label) {
      style.width = `${this.props.size * 1.28571429}px`;
    } else {
      style.textAlign = 'left';
    }

    const {
      active,
      animate,
      className,
      disabled,
      expanded,
      icon,
      inverted,
      flip,
      overlay,
      pressed,
      tabIndex,
      title,
    } = this.props;

    const classes = classNames(className, 'icon-button', {
      active,
      disabled,
      inverted,
      overlayed: overlay,
    });

    const flipDeg = flip ? -180 : -360;
    const rotateDeg = active ? flipDeg : 0;

    const motionDefaultStyle = {
      rotate: rotateDeg,
    };

    const springOpts = {
      stiffness: this.props.flip ? 60 : 120,
      damping: 7,
    };
    const motionStyle = {
      rotate: animate ? spring(rotateDeg, springOpts) : 0,
    };

    if (!animate) {
      // Perf optimization: avoid unnecessary <Motion> components unless
      // we actually need to animate.
      return (
        <button
          aria-label={title}
          aria-pressed={pressed}
          aria-expanded={expanded}
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
          <Icon id={icon} fixedWidth aria-hidden='true' />
        </button>
      );
    }

    return (
      <Motion defaultStyle={motionDefaultStyle} style={motionStyle}>
        {({ rotate }) =>
          (<button
            aria-label={title}
            aria-pressed={pressed}
            aria-expanded={expanded}
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
            <Icon id={icon} style={{ transform: `rotate(${rotate}deg)` }} fixedWidth aria-hidden='true' />
            {this.props.label}
          </button>)
        }
      </Motion>
    );
  }

}

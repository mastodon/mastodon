import React from 'react';
import Motion from '../features/ui/util/optional_motion';
import spring from 'react-motion/lib/spring';
import classNames from 'classnames';
import IconButton from './icon_button';

export default class FoldButton extends IconButton {

  render () {
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
      animate,
      className,
      disabled,
      expanded,
      icon,
      inverted,
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
          style={style}
          tabIndex={tabIndex}
        >
          <i className={`fa fa-fw fa-${icon}`} aria-hidden='true' />
        </button>
      );
    }

    return (
      <Motion defaultStyle={{ rotate: this.props.active ? 180 : 0 }} style={{ rotate: this.props.animate ? spring(this.props.active ? 0 : 180) : 0 }}>
        {({ rotate }) =>
          (<button
            aria-label={title}
            aria-pressed={pressed}
            aria-expanded={expanded}
            title={title}
            className={classes}
            onClick={this.handleClick}
            style={style}
            tabIndex={tabIndex}
          >
            <i style={{ transform: `rotate(${rotate}deg)` }} className={`fa fa-fw fa-${icon}`} aria-hidden='true' />
          </button>)
        }
      </Motion>
    );
  }

}

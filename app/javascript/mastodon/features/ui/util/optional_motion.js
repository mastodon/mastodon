// Like react-motion's Motion, but checks to see if the user prefers
// reduced motion and uses a cross-fade in those cases.

import React from 'react';
import Motion from 'react-motion/lib/Motion';
import PropTypes from 'prop-types';
import { reduceMotion } from '../../../initial_state';

const stylesToKeep = ['opacity', 'backgroundOpacity'];

const extractValue = (value) => {
  // This is either an object with a "val" property or it's a number
  return (typeof value === 'object' && value && 'val' in value) ? value.val : value;
};

class OptionalMotion extends React.Component {

  static propTypes = {
    defaultStyle: PropTypes.object,
    style: PropTypes.object,
    children: PropTypes.func,
  }

  render() {

    const { style, defaultStyle, children } = this.props;

    if (reduceMotion) {
      Object.keys(style).forEach(key => {
        if (stylesToKeep.includes(key)) {
          return;
        }
        // If it's setting an x or height or scale or some other value, we need
        // to preserve the end-state value without actually animating it
        style[key] = defaultStyle[key] = extractValue(style[key]);
      });
    }

    return (
      <Motion style={style} defaultStyle={defaultStyle}>
        {children}
      </Motion>
    );
  }

}


export default OptionalMotion;

import React from 'react';
import Motion from 'react-motion/lib/Motion';
import spring from 'react-motion/lib/spring';
import PropTypes from 'prop-types';

const Collapsable = ({ isVisible, children }) => (
  <Motion defaultStyle={{ opacity: !isVisible ? 0 : 100 }} style={{ opacity: spring(!isVisible ? 0 : 100) }}>
    {({ opacity }) =>
      <div style={{ opacity: opacity / 100, display: Math.floor(opacity) === 0 ? 'none' : 'block', marginBottom: '15px' }}>
        {children}
      </div>
    }
  </Motion>
);

Collapsable.propTypes = {
  isVisible: PropTypes.bool.isRequired,
  children: PropTypes.node.isRequired,
};

export default Collapsable;

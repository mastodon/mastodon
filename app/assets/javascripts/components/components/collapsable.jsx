import { Motion, spring } from 'react-motion';
import PropTypes from 'prop-types';

const Collapsable = ({ fullHeight, isVisible, children }) => (
  <Motion defaultStyle={{ opacity: !isVisible ? 0 : 100, height: isVisible ? fullHeight : 0 }} style={{ opacity: spring(!isVisible ? 0 : 100), height: spring(!isVisible ? 0 : fullHeight) }}>
    {({ opacity, height }) =>
      <div style={{ height: `${height}px`, overflow: 'hidden', opacity: opacity / 100, display: Math.floor(opacity) === 0 ? 'none' : 'block' }}>
        {children}
      </div>
    }
  </Motion>
);

Collapsable.propTypes = {
  fullHeight: PropTypes.number.isRequired,
  isVisible: PropTypes.bool.isRequired,
  children: PropTypes.node.isRequired
};

export default Collapsable;

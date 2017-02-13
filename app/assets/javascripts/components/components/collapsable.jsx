import { Motion, spring } from 'react-motion';

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
  fullHeight: React.PropTypes.number.isRequired,
  isVisible: React.PropTypes.bool.isRequired,
  children: React.PropTypes.node.isRequired
};

export default Collapsable;

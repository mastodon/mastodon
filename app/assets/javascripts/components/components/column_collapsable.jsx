import { Motion, spring } from 'react-motion';
import PropTypes from 'prop-types';

class ColumnCollapsable extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.state = {
      collapsed: true
    };

    this.handleToggleCollapsed = this.handleToggleCollapsed.bind(this);
  }

  handleToggleCollapsed () {
    const currentState = this.state.collapsed;

    this.setState({ collapsed: !currentState });

    if (!currentState && this.props.onCollapse) {
      this.props.onCollapse();
    }
  }

  render () {
    const { icon, title, fullHeight, children } = this.props;
    const { collapsed } = this.state;
    const collapsedClassName = collapsed ? 'collapsable-collapsed' : 'collapsable';

    return (
      <div className='column-collapsable'>
        <div role='button' tabIndex='0' title={`${title}`} className={`column-icon ${collapsedClassName}`} onClick={this.handleToggleCollapsed}>
          <i className={`fa fa-${icon}`} />
        </div>

        <Motion defaultStyle={{ opacity: 0, height: 0 }} style={{ opacity: spring(collapsed ? 0 : 100), height: spring(collapsed ? 0 : fullHeight, collapsed ? undefined : { stiffness: 150, damping: 9 }) }}>
          {({ opacity, height }) =>
            <div style={{ overflow: height === fullHeight ? 'auto' : 'hidden', height: `${height}px`, opacity: opacity / 100, maxHeight: '70vh' }}>
              {children}
            </div>
          }
        </Motion>
      </div>
    );
  }
}

ColumnCollapsable.propTypes = {
  icon: PropTypes.string.isRequired,
  title: PropTypes.string,
  fullHeight: PropTypes.number.isRequired,
  children: PropTypes.node,
  onCollapse: PropTypes.func
};

export default ColumnCollapsable;

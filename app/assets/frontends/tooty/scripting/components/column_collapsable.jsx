import PureRenderMixin from 'react-addons-pure-render-mixin';
import { Motion, spring } from 'react-motion';

const iconStyle = {
  fontSize: '16px',
  padding: '15px',
  position: 'absolute',
  right: '0',
  top: '-48px',
  cursor: 'pointer',
  zIndex: '3'
};

const ColumnCollapsable = React.createClass({

  propTypes: {
    icon: React.PropTypes.string.isRequired,
    title: React.PropTypes.string,
    fullHeight: React.PropTypes.number.isRequired,
    children: React.PropTypes.node,
    onCollapse: React.PropTypes.func
  },

  getInitialState () {
    return {
      collapsed: true
    };
  },

  mixins: [PureRenderMixin],

  handleToggleCollapsed () {
    const currentState = this.state.collapsed;

    this.setState({ collapsed: !currentState });

    if (!currentState && this.props.onCollapse) {
      this.props.onCollapse();
    }
  },

  render () {
    const { icon, title, fullHeight, children } = this.props;
    const { collapsed } = this.state;
    const collapsedClassName = collapsed ? 'collapsable-collapsed' : 'collapsable';

    return (
      <div style={{ position: 'relative' }}>
        <div role='button' tabIndex='0' title={`${title}`} style={{...iconStyle }} className={`column-icon ${collapsedClassName}`} onClick={this.handleToggleCollapsed}>
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
});

export default ColumnCollapsable;

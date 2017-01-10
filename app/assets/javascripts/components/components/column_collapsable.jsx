import PureRenderMixin from 'react-addons-pure-render-mixin';
import { Motion, spring } from 'react-motion';

const iconStyle = {
  fontSize: '16px',
  padding: '15px',
  position: 'absolute',
  right: '0',
  top: '-48px',
  cursor: 'pointer'
};

const ColumnCollapsable = React.createClass({

  propTypes: {
    icon: React.PropTypes.string.isRequired,
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
    const { icon, fullHeight, children } = this.props;
    const { collapsed } = this.state;

    return (
      <div style={{ position: 'relative' }}>
        <div style={{...iconStyle, color: collapsed ? '#9baec8' : '#fff', background: collapsed ? '#2f3441' : '#373b4a' }} onClick={this.handleToggleCollapsed}><i className={`fa fa-${icon}`} /></div>

        <Motion defaultStyle={{ opacity: 0, height: 0 }} style={{ opacity: spring(collapsed ? 0 : 100), height: spring(collapsed ? 0 : fullHeight) }}>
          {({ opacity, height }) =>
            <div style={{ overflow: 'hidden', height: `${height}px`, opacity: opacity / 100 }}>
              {children}
            </div>
          }
        </Motion>
      </div>
    );
  }
});

export default ColumnCollapsable;

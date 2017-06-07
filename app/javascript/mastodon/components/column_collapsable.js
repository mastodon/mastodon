import React from 'react';
import PropTypes from 'prop-types';

class ColumnCollapsable extends React.PureComponent {

  static propTypes = {
    icon: PropTypes.string.isRequired,
    title: PropTypes.string,
    fullHeight: PropTypes.number.isRequired,
    children: PropTypes.node,
    onCollapse: PropTypes.func,
  };

  state = {
    collapsed: true,
    animating: false,
  };

  handleToggleCollapsed = () => {
    const currentState = this.state.collapsed;

    this.setState({ collapsed: !currentState, animating: true });

    if (!currentState && this.props.onCollapse) {
      this.props.onCollapse();
    }
  }

  handleTransitionEnd = () => {
    this.setState({ animating: false });
  }

  render () {
    const { icon, title, fullHeight, children } = this.props;
    const { collapsed, animating } = this.state;

    return (
      <div className={`column-collapsable ${collapsed ? 'collapsed' : ''}`} onTransitionEnd={this.handleTransitionEnd}>
        <div role='button' tabIndex='0' title={`${title}`} className='column-collapsable__button column-icon' onClick={this.handleToggleCollapsed}>
          <i className={`fa fa-${icon}`} />
        </div>

        <div className='column-collapsable__content' style={{ height: `${fullHeight}px` }}>
          {(!collapsed || animating) && children}
        </div>
      </div>
    );
  }

}

export default ColumnCollapsable;

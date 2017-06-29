import React from 'react';
import PropTypes from 'prop-types';
import scrollTop from '../scroll';

export default class Column extends React.PureComponent {

  static propTypes = {
    children: PropTypes.node,
    visible: PropTypes.bool,
  };

  static defaultProps = {
    visible: true,
  }

  scrollTop () {
    const scrollable = this.node.querySelector('.scrollable');

    if (!scrollable) {
      return;
    }

    this._interruptScrollAnimation = scrollTop(scrollable);
  }

  handleWheel = () => {
    if (typeof this._interruptScrollAnimation !== 'function') {
      return;
    }

    this._interruptScrollAnimation();
  }

  setRef = c => {
    this.node = c;
  }

  render () {
    const { children, visible } = this.props;

    const visibleClass = visible ? '' : 'column--hidden';

    return (
      <div role='region' aria-hidden={!visible} className={`column ${visibleClass}`} ref={this.setRef} onWheel={this.handleWheel}>
        {children}
      </div>
    );
  }

}

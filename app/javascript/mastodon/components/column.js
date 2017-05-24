import React from 'react';
import PropTypes from 'prop-types';
import scrollTop from '../scroll';

class Column extends React.PureComponent {

  static propTypes = {
    children: PropTypes.node,
  };

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
    const { children } = this.props;

    return (
      <div role='region' className='column' ref={this.setRef} onWheel={this.handleWheel}>
        {children}
      </div>
    );
  }

}

export default Column;

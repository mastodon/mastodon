import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { supportsPassiveEvents } from 'detect-passive-events';

import { scrollTop } from '../scroll';

const listenerOptions = supportsPassiveEvents ? { passive: true } : false;

export default class Column extends PureComponent {

  static propTypes = {
    children: PropTypes.node,
    label: PropTypes.string,
    bindToDocument: PropTypes.bool,
  };

  scrollTop () {
    let scrollable = null;

    if (this.props.bindToDocument) {
      scrollable = document.scrollingElement;
    } else {
      scrollable = this.node.querySelector('.scrollable');
    }

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
  };

  setRef = c => {
    this.node = c;
  };

  componentDidMount () {
    if (this.props.bindToDocument) {
      document.addEventListener('wheel', this.handleWheel, listenerOptions);
    } else {
      this.node.addEventListener('wheel', this.handleWheel, listenerOptions);
    }
  }

  componentWillUnmount () {
    if (this.props.bindToDocument) {
      document.removeEventListener('wheel', this.handleWheel, listenerOptions);
    } else {
      this.node.removeEventListener('wheel', this.handleWheel, listenerOptions);
    }
  }

  render () {
    const { label, children } = this.props;

    return (
      <div role='region' aria-label={label} className='column' ref={this.setRef}>
        {children}
      </div>
    );
  }

}

import React from 'react';
import PropTypes from 'prop-types';
import { supportsPassiveEvents } from 'detect-passive-events';
import { scrollTop } from '../scroll';

export default class Column extends React.PureComponent {

  static propTypes = {
    children: PropTypes.node,
    extraClasses: PropTypes.string,
    name: PropTypes.string,
    label: PropTypes.string,
    bindToDocument: PropTypes.bool,
  };

  scrollTop () {
    const scrollable = this.props.bindToDocument ? document.scrollingElement : this.node.querySelector('.scrollable');

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
      document.addEventListener('wheel', this.handleWheel, supportsPassiveEvents ? { passive: true } : false);
    } else {
      this.node.addEventListener('wheel', this.handleWheel, supportsPassiveEvents ? { passive: true } : false);
    }
  }

  componentWillUnmount () {
    if (this.props.bindToDocument) {
      document.removeEventListener('wheel', this.handleWheel);
    } else {
      this.node.removeEventListener('wheel', this.handleWheel);
    }
  }

  render () {
    const { children, extraClasses, name, label } = this.props;

    return (
      <div role='region' aria-label={label} data-column={name} className={`column ${extraClasses || ''}`} ref={this.setRef}>
        {children}
      </div>
    );
  }

}

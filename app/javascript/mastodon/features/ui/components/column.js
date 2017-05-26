import React from 'react';
import ColumnHeader from './column_header';
import PropTypes from 'prop-types';
import { debounce } from 'lodash';

const easingOutQuint = (x, t, b, c, d) => c*((t=t/d-1)*t*t*t*t + 1) + b;

const scrollTop = (node) => {
  const startTime = Date.now();
  const offset    = node.scrollTop;
  const targetY   = -offset;
  const duration  = 1000;
  let interrupt   = false;

  const step = () => {
    const elapsed    = Date.now() - startTime;
    const percentage = elapsed / duration;

    if (percentage > 1 || interrupt) {
      return;
    }

    node.scrollTop = easingOutQuint(0, elapsed, offset, targetY, duration);
    requestAnimationFrame(step);
  };

  step();

  return () => {
    interrupt = true;
  };
};

class Column extends React.PureComponent {

  static propTypes = {
    heading: PropTypes.string,
    icon: PropTypes.string,
    children: PropTypes.node,
    active: PropTypes.bool,
    hideHeadingOnMobile: PropTypes.bool,
  };

  handleHeaderClick = () => {
    const scrollable = this.node.querySelector('.scrollable');
    if (!scrollable) {
      return;
    }
    this._interruptScrollAnimation = scrollTop(scrollable);
  }

  handleScroll = debounce(() => {
    if (typeof this._interruptScrollAnimation !== 'undefined') {
      this._interruptScrollAnimation();
    }
  }, 200)

  setRef = (c) => {
    this.node = c;
  }

  render () {
    const { heading, icon, children, active, hideHeadingOnMobile } = this.props;

    let columnHeaderId = null;
    let header = '';

    if (heading) {
      columnHeaderId = heading.replace(/ /g, '-');
      header = <ColumnHeader icon={icon} active={active} type={heading} onClick={this.handleHeaderClick} hideOnMobile={hideHeadingOnMobile} columnHeaderId={columnHeaderId}/>;
    }
    return (
      <div
        ref={this.setRef}
        role='region'
        aria-labelledby={columnHeaderId}
        className='column'
        onScroll={this.handleScroll}>
        {header}
        {children}
      </div>
    );
  }

}

export default Column;

import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { debounce } from 'lodash';

import { isMobile } from '../../../is_mobile';
import { scrollTop } from '../../../scroll';

import ColumnHeader from './column_header';

export default class Column extends PureComponent {

  static propTypes = {
    heading: PropTypes.string,
    icon: PropTypes.string,
    iconComponent: PropTypes.func,
    children: PropTypes.node,
    active: PropTypes.bool,
    hideHeadingOnMobile: PropTypes.bool,
    name: PropTypes.string,
    bindToDocument: PropTypes.bool,
  };

  handleHeaderClick = () => {
    const scrollable = this.props.bindToDocument ? document.scrollingElement : this.node.querySelector('.scrollable');

    if (!scrollable) {
      return;
    }

    this._interruptScrollAnimation = scrollTop(scrollable);
  };

  scrollTop () {
    const scrollable = this.props.bindToDocument ? document.scrollingElement : this.node.querySelector('.scrollable');

    if (!scrollable) {
      return;
    }

    this._interruptScrollAnimation = scrollTop(scrollable);
  }


  handleScroll = debounce(() => {
    if (typeof this._interruptScrollAnimation !== 'undefined') {
      this._interruptScrollAnimation();
    }
  }, 200);

  setRef = (c) => {
    this.node = c;
  };

  render () {
    const { heading, icon, iconComponent, children, active, hideHeadingOnMobile, name } = this.props;

    const showHeading = heading && (!hideHeadingOnMobile || (hideHeadingOnMobile && !isMobile(window.innerWidth)));

    const columnHeaderId = showHeading && heading.replace(/ /g, '-');
    const header = showHeading && (
      <ColumnHeader icon={icon} iconComponent={iconComponent} active={active} type={heading} onClick={this.handleHeaderClick} columnHeaderId={columnHeaderId} />
    );
    return (
      <div
        ref={this.setRef}
        role='region'
        data-column={name}
        aria-labelledby={columnHeaderId}
        className='column'
        onScroll={this.handleScroll}
      >
        {header}
        {children}
      </div>
    );
  }

}

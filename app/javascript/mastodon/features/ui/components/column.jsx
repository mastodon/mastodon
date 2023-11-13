import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { debounce } from 'lodash';

import ColumnHeader from '../../../components/column_header';
import { isMobile } from '../../../is_mobile';
import { scrollTop } from '../../../scroll';

export default class Column extends PureComponent {

  static propTypes = {
    heading: PropTypes.string,
    alwaysShowBackButton: PropTypes.bool,
    icon: PropTypes.string,
    iconComponent: PropTypes.func,
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
  };

  scrollTop () {
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
  }, 200);

  setRef = (c) => {
    this.node = c;
  };

  render () {
    const { heading, icon, iconComponent, children, active, hideHeadingOnMobile, alwaysShowBackButton } = this.props;

    const showHeading = heading && (!hideHeadingOnMobile || (hideHeadingOnMobile && !isMobile(window.innerWidth)));

    const columnHeaderId = showHeading && heading.replace(/ /g, '-');

    const header = showHeading && (
      <ColumnHeader icon={icon} iconComponent={iconComponent} active={active} title={heading} onClick={this.handleHeaderClick} columnHeaderId={columnHeaderId} showBackButton={alwaysShowBackButton} />
    );
    return (
      <div
        ref={this.setRef}
        role='region'
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

import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import IconButton from './icon_button';
import Overlay from 'react-overlays/lib/Overlay';
import Motion from '../features/ui/util/optional_motion';
import spring from 'react-motion/lib/spring';
import detectPassiveEvents from 'detect-passive-events';

const listenerOptions = detectPassiveEvents.hasSupport ? { passive: true } : false;
let id = 0;

class DropdownMenu extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    items: PropTypes.array.isRequired,
    onClose: PropTypes.func.isRequired,
    style: PropTypes.object,
    placement: PropTypes.string,
    arrowOffsetLeft: PropTypes.string,
    arrowOffsetTop: PropTypes.string,
  };

  static defaultProps = {
    style: {},
    placement: 'bottom',
  };

  state = {
    mounted: false,
  };

  handleDocumentClick = e => {
    if (this.node && !this.node.contains(e.target)) {
      this.props.onClose();
    }
  }

  componentDidMount () {
    document.addEventListener('click', this.handleDocumentClick, false);
    document.addEventListener('touchend', this.handleDocumentClick, listenerOptions);
    if (this.focusedItem) this.focusedItem.focus();
    this.setState({ mounted: true });
  }

  componentWillUnmount () {
    document.removeEventListener('click', this.handleDocumentClick, false);
    document.removeEventListener('touchend', this.handleDocumentClick, listenerOptions);
  }

  setRef = c => {
    this.node = c;
  }

  setFocusRef = c => {
    this.focusedItem = c;
  }

  handleKeyDown = e => {
    const items = Array.from(this.node.getElementsByTagName('a'));
    const index = items.indexOf(e.currentTarget);
    let element;

    switch(e.key) {
    case 'Enter':
      this.handleClick(e);
      break;
    case 'ArrowDown':
      element = items[index+1];
      if (element) {
        element.focus();
      }
      break;
    case 'ArrowUp':
      element = items[index-1];
      if (element) {
        element.focus();
      }
      break;
    case 'Home':
      element = items[0];
      if (element) {
        element.focus();
      }
      break;
    case 'End':
      element = items[items.length-1];
      if (element) {
        element.focus();
      }
      break;
    }
  }

  handleClick = e => {
    const i = Number(e.currentTarget.getAttribute('data-index'));
    const { action, to } = this.props.items[i];

    this.props.onClose();

    if (typeof action === 'function') {
      e.preventDefault();
      action(e);
    } else if (to) {
      e.preventDefault();
      this.context.router.history.push(to);
    }
  }

  renderItem (option, i) {
    if (option === null) {
      return <li key={`sep-${i}`} className='dropdown-menu__separator' />;
    }

    const { text, href = '#' } = option;

    return (
      <li className='dropdown-menu__item' key={`${text}-${i}`}>
        <a href={href} target='_blank' rel='noopener' role='button' tabIndex='0' ref={i === 0 ? this.setFocusRef : null} onClick={this.handleClick} onKeyDown={this.handleKeyDown} data-index={i}>
          {text}
        </a>
      </li>
    );
  }

  render () {
    const { items, style, placement, arrowOffsetLeft, arrowOffsetTop } = this.props;
    const { mounted } = this.state;

    return (
      <Motion defaultStyle={{ opacity: 0, scaleX: 0.85, scaleY: 0.75 }} style={{ opacity: spring(1, { damping: 35, stiffness: 400 }), scaleX: spring(1, { damping: 35, stiffness: 400 }), scaleY: spring(1, { damping: 35, stiffness: 400 }) }}>
        {({ opacity, scaleX, scaleY }) => (
          // It should not be transformed when mounting because the resulting
          // size will be used to determine the coordinate of the menu by
          // react-overlays
          <div className='dropdown-menu' style={{ ...style, opacity: opacity, transform: mounted ? `scale(${scaleX}, ${scaleY})` : null }} ref={this.setRef}>
            <div className={`dropdown-menu__arrow ${placement}`} style={{ left: arrowOffsetLeft, top: arrowOffsetTop }} />

            <ul>
              {items.map((option, i) => this.renderItem(option, i))}
            </ul>
          </div>
        )}
      </Motion>
    );
  }

}

export default class Dropdown extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    icon: PropTypes.string.isRequired,
    items: PropTypes.array.isRequired,
    size: PropTypes.number.isRequired,
    title: PropTypes.string,
    disabled: PropTypes.bool,
    status: ImmutablePropTypes.map,
    isUserTouching: PropTypes.func,
    isModalOpen: PropTypes.bool.isRequired,
    onOpen: PropTypes.func.isRequired,
    onClose: PropTypes.func.isRequired,
    dropdownPlacement: PropTypes.string,
    openDropdownId: PropTypes.number,
  };

  static defaultProps = {
    title: 'Menu',
  };

  state = {
    id: id++,
  };

  handleClick = ({ target }) => {
    if (this.state.id === this.props.openDropdownId) {
      this.handleClose();
    } else {
      const { top } = target.getBoundingClientRect();
      const placement = top * 2 < innerHeight ? 'bottom' : 'top';

      this.props.onOpen(this.state.id, this.handleItemClick, placement);
    }
  }

  handleClose = () => {
    this.props.onClose(this.state.id);
  }

  handleKeyDown = e => {
    switch(e.key) {
    case 'Escape':
      this.handleClose();
      break;
    }
  }

  handleItemClick = e => {
    const i = Number(e.currentTarget.getAttribute('data-index'));
    const { action, to } = this.props.items[i];

    this.handleClose();

    if (typeof action === 'function') {
      e.preventDefault();
      action();
    } else if (to) {
      e.preventDefault();
      this.context.router.history.push(to);
    }
  }

  setTargetRef = c => {
    this.target = c;
  }

  findTarget = () => {
    return this.target;
  }

  render () {
    const { icon, items, size, title, disabled, dropdownPlacement, openDropdownId } = this.props;
    const open = this.state.id === openDropdownId;

    return (
      <div onKeyDown={this.handleKeyDown}>
        <IconButton
          icon={icon}
          title={title}
          active={open}
          disabled={disabled}
          size={size}
          ref={this.setTargetRef}
          onClick={this.handleClick}
        />

        <Overlay show={open} placement={dropdownPlacement} target={this.findTarget}>
          <DropdownMenu items={items} onClose={this.handleClose} />
        </Overlay>
      </div>
    );
  }

}

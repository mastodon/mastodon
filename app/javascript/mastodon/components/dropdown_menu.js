import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import IconButton from './icon_button';
import Overlay from 'react-overlays/Overlay';
import { supportsPassiveEvents } from 'detect-passive-events';
import classNames from 'classnames';
import { CircularProgress } from 'mastodon/components/loading_indicator';

const listenerOptions = supportsPassiveEvents ? { passive: true } : false;
let id = 0;

class DropdownMenu extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    items: PropTypes.oneOfType([PropTypes.array, ImmutablePropTypes.list]).isRequired,
    loading: PropTypes.bool,
    scrollable: PropTypes.bool,
    onClose: PropTypes.func.isRequired,
    style: PropTypes.object,
    openedViaKeyboard: PropTypes.bool,
    renderItem: PropTypes.func,
    renderHeader: PropTypes.func,
    onItemClick: PropTypes.func.isRequired,
  };

  static defaultProps = {
    style: {},
  };

  handleDocumentClick = e => {
    if (this.node && !this.node.contains(e.target)) {
      this.props.onClose();
    }
  };

  componentDidMount () {
    document.addEventListener('click', this.handleDocumentClick, false);
    document.addEventListener('keydown', this.handleKeyDown, false);
    document.addEventListener('touchend', this.handleDocumentClick, listenerOptions);

    if (this.focusedItem && this.props.openedViaKeyboard) {
      this.focusedItem.focus({ preventScroll: true });
    }
  }

  componentWillUnmount () {
    document.removeEventListener('click', this.handleDocumentClick, false);
    document.removeEventListener('keydown', this.handleKeyDown, false);
    document.removeEventListener('touchend', this.handleDocumentClick, listenerOptions);
  }

  setRef = c => {
    this.node = c;
  };

  setFocusRef = c => {
    this.focusedItem = c;
  };

  handleKeyDown = e => {
    const items = Array.from(this.node.querySelectorAll('a, button'));
    const index = items.indexOf(document.activeElement);
    let element = null;

    switch(e.key) {
    case 'ArrowDown':
      element = items[index+1] || items[0];
      break;
    case 'ArrowUp':
      element = items[index-1] || items[items.length-1];
      break;
    case 'Tab':
      if (e.shiftKey) {
        element = items[index-1] || items[items.length-1];
      } else {
        element = items[index+1] || items[0];
      }
      break;
    case 'Home':
      element = items[0];
      break;
    case 'End':
      element = items[items.length-1];
      break;
    case 'Escape':
      this.props.onClose();
      break;
    }

    if (element) {
      element.focus();
      e.preventDefault();
      e.stopPropagation();
    }
  };

  handleItemKeyPress = e => {
    if (e.key === 'Enter' || e.key === ' ') {
      this.handleClick(e);
    }
  };

  handleClick = e => {
    const { onItemClick } = this.props;
    onItemClick(e);
  };

  renderItem = (option, i) => {
    if (option === null) {
      return <li key={`sep-${i}`} className='dropdown-menu__separator' />;
    }

    const { text, href = '#', target = '_blank', method } = option;

    return (
      <li className='dropdown-menu__item' key={`${text}-${i}`}>
        <a href={href} target={target} data-method={method} rel='noopener noreferrer' role='button' tabIndex='0' ref={i === 0 ? this.setFocusRef : null} onClick={this.handleClick} onKeyPress={this.handleItemKeyPress} data-index={i}>
          {text}
        </a>
      </li>
    );
  };

  render () {
    const { items, scrollable, renderHeader, loading } = this.props;

    let renderItem = this.props.renderItem || this.renderItem;

    return (
      <div className={classNames('dropdown-menu__container', { 'dropdown-menu__container--loading': loading })} ref={this.setRef}>
        {loading && (
          <CircularProgress size={30} strokeWidth={3.5} />
        )}

        {!loading && renderHeader && (
          <div className='dropdown-menu__container__header'>
            {renderHeader(items)}
          </div>
        )}

        {!loading && (
          <ul className={classNames('dropdown-menu__container__list', { 'dropdown-menu__container__list--scrollable': scrollable })}>
            {items.map((option, i) => renderItem(option, i, { onClick: this.handleClick, onKeyPress: this.handleItemKeyPress }))}
          </ul>
        )}
      </div>
    );
  }

}

export default class Dropdown extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    children: PropTypes.node,
    icon: PropTypes.string,
    items: PropTypes.oneOfType([PropTypes.array, ImmutablePropTypes.list]).isRequired,
    loading: PropTypes.bool,
    size: PropTypes.number,
    title: PropTypes.string,
    disabled: PropTypes.bool,
    scrollable: PropTypes.bool,
    status: ImmutablePropTypes.map,
    isUserTouching: PropTypes.func,
    onOpen: PropTypes.func.isRequired,
    onClose: PropTypes.func.isRequired,
    openDropdownId: PropTypes.number,
    openedViaKeyboard: PropTypes.bool,
    renderItem: PropTypes.func,
    renderHeader: PropTypes.func,
    onItemClick: PropTypes.func,
  };

  static defaultProps = {
    title: 'Menu',
  };

  state = {
    id: id++,
  };

  handleClick = ({ type }) => {
    if (this.state.id === this.props.openDropdownId) {
      this.handleClose();
    } else {
      this.props.onOpen(this.state.id, this.handleItemClick, type !== 'click');
    }
  };

  handleClose = () => {
    if (this.activeElement) {
      this.activeElement.focus({ preventScroll: true });
      this.activeElement = null;
    }
    this.props.onClose(this.state.id);
  };

  handleMouseDown = () => {
    if (!this.state.open) {
      this.activeElement = document.activeElement;
    }
  };

  handleButtonKeyDown = (e) => {
    switch(e.key) {
    case ' ':
    case 'Enter':
      this.handleMouseDown();
      break;
    }
  };

  handleKeyPress = (e) => {
    switch(e.key) {
    case ' ':
    case 'Enter':
      this.handleClick(e);
      e.stopPropagation();
      e.preventDefault();
      break;
    }
  };

  handleItemClick = e => {
    const { onItemClick } = this.props;
    const i = Number(e.currentTarget.getAttribute('data-index'));
    const item = this.props.items[i];

    this.handleClose();

    if (typeof onItemClick === 'function') {
      e.preventDefault();
      onItemClick(item, i);
    } else if (item && typeof item.action === 'function') {
      e.preventDefault();
      item.action();
    } else if (item && item.to) {
      e.preventDefault();
      this.context.router.history.push(item.to);
    }
  };

  setTargetRef = c => {
    this.target = c;
  };

  findTarget = () => {
    return this.target;
  };

  componentWillUnmount = () => {
    if (this.state.id === this.props.openDropdownId) {
      this.handleClose();
    }
  };

  close = () => {
    this.handleClose();
  };

  render () {
    const {
      icon,
      items,
      size,
      title,
      disabled,
      loading,
      scrollable,
      openDropdownId,
      openedViaKeyboard,
      children,
      renderItem,
      renderHeader,
    } = this.props;

    const open = this.state.id === openDropdownId;

    const button = children ? React.cloneElement(React.Children.only(children), {
      onClick: this.handleClick,
      onMouseDown: this.handleMouseDown,
      onKeyDown: this.handleButtonKeyDown,
      onKeyPress: this.handleKeyPress,
    }) : (
      <IconButton
        icon={icon}
        title={title}
        active={open}
        disabled={disabled}
        size={size}
        onClick={this.handleClick}
        onMouseDown={this.handleMouseDown}
        onKeyDown={this.handleButtonKeyDown}
        onKeyPress={this.handleKeyPress}
      />
    );

    return (
      <React.Fragment>
        <span ref={this.setTargetRef}>
          {button}
        </span>
        <Overlay show={open} offset={[5, 5]} placement={'bottom'} flip target={this.findTarget} popperConfig={{ strategy: 'fixed' }}>
          {({ props, arrowProps, placement }) => (
            <div {...props}>
              <div className={`dropdown-animation dropdown-menu ${placement}`}>
                <div className={`dropdown-menu__arrow ${placement}`} {...arrowProps} />
                <DropdownMenu
                  items={items}
                  loading={loading}
                  scrollable={scrollable}
                  onClose={this.handleClose}
                  openedViaKeyboard={openedViaKeyboard}
                  renderItem={renderItem}
                  renderHeader={renderHeader}
                  onItemClick={this.handleItemClick}
                />
              </div>
            </div>
          )}
        </Overlay>
      </React.Fragment>
    );
  }

}

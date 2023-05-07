//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';
import Overlay from 'react-overlays/Overlay';

//  Components.
import IconButton from 'flavours/glitch/components/icon_button';
import DropdownMenu from './dropdown_menu';

//  The component.
export default class ComposerOptionsDropdown extends React.PureComponent {

  static propTypes = {
    isUserTouching: PropTypes.func,
    disabled: PropTypes.bool,
    icon: PropTypes.string,
    items: PropTypes.arrayOf(PropTypes.shape({
      icon: PropTypes.string,
      meta: PropTypes.string,
      name: PropTypes.string.isRequired,
      text: PropTypes.string,
    })).isRequired,
    onModalOpen: PropTypes.func,
    onModalClose: PropTypes.func,
    title: PropTypes.string,
    value: PropTypes.string,
    onChange: PropTypes.func,
    container: PropTypes.func,
    renderItemContents: PropTypes.func,
    closeOnChange: PropTypes.bool,
  };

  static defaultProps = {
    closeOnChange: true,
  };

  state = {
    open: false,
    openedViaKeyboard: undefined,
    placement: 'bottom',
  };

  //  Toggles opening and closing the dropdown.
  handleToggle = ({ type }) => {
    const { onModalOpen } = this.props;
    const { open } = this.state;

    if (this.props.isUserTouching && this.props.isUserTouching()) {
      if (open) {
        this.props.onModalClose();
      } else {
        const modal = this.handleMakeModal();
        if (modal && onModalOpen) {
          onModalOpen(modal);
        }
      }
    } else {
      if (open && this.activeElement) {
        this.activeElement.focus({ preventScroll: true });
      }
      this.setState({ open: !open, openedViaKeyboard: type !== 'click' });
    }
  };

  handleKeyDown = (e) => {
    switch (e.key) {
    case 'Escape':
      this.handleClose();
      break;
    }
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
      this.handleToggle(e);
      e.stopPropagation();
      e.preventDefault();
      break;
    }
  };

  handleClose = () => {
    if (this.state.open && this.activeElement) {
      this.activeElement.focus({ preventScroll: true });
    }
    this.setState({ open: false });
  };

  handleItemClick = (e) => {
    const {
      items,
      onChange,
      onModalClose,
      closeOnChange,
    } = this.props;

    const i = Number(e.currentTarget.getAttribute('data-index'));

    const { name } = items[i];

    e.preventDefault();  //  Prevents focus from changing
    if (closeOnChange) onModalClose();
    onChange(name);
  };

  //  Creates an action modal object.
  handleMakeModal = () => {
    const {
      items,
      onChange,
      onModalOpen,
      onModalClose,
      value,
    } = this.props;

    //  Required props.
    if (!(onChange && onModalOpen && onModalClose && items)) {
      return null;
    }

    //  The object.
    return {
      renderItemContents: this.props.renderItemContents,
      onClick: this.handleItemClick,
      actions: items.map(
        ({
          name,
          ...rest
        }) => ({
          ...rest,
          active: value && name === value,
          name,
        }),
      ),
    };
  };

  setTargetRef = c => {
    this.target = c;
  };

  findTarget = () => {
    return this.target;
  };

  handleOverlayEnter = (state) => {
    this.setState({ placement: state.placement });
  };

  //  Rendering.
  render () {
    const {
      disabled,
      title,
      icon,
      items,
      onChange,
      value,
      container,
      renderItemContents,
      closeOnChange,
    } = this.props;
    const { open, placement } = this.state;

    const active = value && items.findIndex(({ name }) => name === value) === (placement === 'bottom' ? 0 : (items.length - 1));

    return (
      <div
        className={classNames('privacy-dropdown', placement, { active: open })}
        onKeyDown={this.handleKeyDown}
        ref={this.setTargetRef}
      >
        <div className={classNames('privacy-dropdown__value', { active })}>
          <IconButton
            active={open}
            className='privacy-dropdown__value-icon'
            disabled={disabled}
            icon={icon}
            inverted
            onClick={this.handleToggle}
            onMouseDown={this.handleMouseDown}
            onKeyDown={this.handleButtonKeyDown}
            onKeyPress={this.handleKeyPress}
            size={18}
            style={{
              height: null,
              lineHeight: '27px',
            }}
            title={title}
          />
        </div>

        <Overlay
          containerPadding={20}
          placement={placement}
          show={open}
          flip
          target={this.findTarget}
          container={container}
          popperConfig={{ strategy: 'fixed', onFirstUpdate: this.handleOverlayEnter }}
        >
          {({ props, placement }) => (
            <div {...props}>
              <div className={`dropdown-animation privacy-dropdown__dropdown ${placement}`}>
                <DropdownMenu
                  items={items}
                  renderItemContents={renderItemContents}
                  onChange={onChange}
                  onClose={this.handleClose}
                  value={value}
                  openedViaKeyboard={this.state.openedViaKeyboard}
                  closeOnChange={closeOnChange}
                />
              </div>
            </div>
          )}
        </Overlay>
      </div>
    );
  }

}

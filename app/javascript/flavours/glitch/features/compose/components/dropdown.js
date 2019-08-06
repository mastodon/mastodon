//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';
import Overlay from 'react-overlays/lib/Overlay';

//  Components.
import IconButton from 'flavours/glitch/components/icon_button';
import DropdownMenu from './dropdown_menu';

//  Utils.
import { isUserTouching } from 'flavours/glitch/util/is_mobile';
import { assignHandlers } from 'flavours/glitch/util/react_helpers';

//  The component.
export default class ComposerOptionsDropdown extends React.PureComponent {

  static propTypes = {
    active: PropTypes.bool,
    disabled: PropTypes.bool,
    icon: PropTypes.string,
    items: PropTypes.arrayOf(PropTypes.shape({
      icon: PropTypes.string,
      meta: PropTypes.node,
      name: PropTypes.string.isRequired,
      on: PropTypes.bool,
      text: PropTypes.node,
    })).isRequired,
    onModalOpen: PropTypes.func,
    onModalClose: PropTypes.func,
    title: PropTypes.string,
    value: PropTypes.string,
    onChange: PropTypes.func,
  };

  state = {
    needsModalUpdate: false,
    open: false,
    openedViaKeyboard: undefined,
    placement: 'bottom',
  };

  //  Toggles opening and closing the dropdown.
  handleToggle = ({ target, type }) => {
    const { onModalOpen } = this.props;
    const { open } = this.state;

    if (isUserTouching()) {
      if (this.state.open) {
        this.props.onModalClose();
      } else {
        const modal = this.handleMakeModal();
        if (modal && onModalOpen) {
          onModalOpen(modal);
        }
      }
    } else {
      const { top } = target.getBoundingClientRect();
      if (this.state.open && this.activeElement) {
        this.activeElement.focus();
      }
      this.setState({ placement: top * 2 < innerHeight ? 'bottom' : 'top' });
      this.setState({ open: !this.state.open, openedViaKeyboard: type !== 'click' });
    }
  }

  handleKeyDown = (e) => {
    switch (e.key) {
    case 'Escape':
      this.handleClose();
      break;
    }
  }

  handleMouseDown = () => {
    if (!this.state.open) {
      this.activeElement = document.activeElement;
    }
  }

  handleButtonKeyDown = (e) => {
    switch(e.key) {
    case ' ':
    case 'Enter':
      this.handleMouseDown();
      break;
    }
  }

  handleKeyPress = (e) => {
    switch(e.key) {
    case ' ':
    case 'Enter':
      this.handleToggle(e);
      e.stopPropagation();
      e.preventDefault();
      break;
    }
  }

  handleClose = () => {
    if (this.state.open && this.activeElement) {
      this.activeElement.focus();
    }
    this.setState({ open: false });
  }

  //  Creates an action modal object.
  handleMakeModal = () => {
    const component = this;
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
      actions: items.map(
        ({
          name,
          ...rest
        }) => ({
          ...rest,
          active: value && name === value,
          name,
          onClick (e) {
            e.preventDefault();  //  Prevents focus from changing
            onModalClose();
            onChange(name);
          },
          onPassiveClick (e) {
            e.preventDefault();  //  Prevents focus from changing
            onChange(name);
            component.setState({ needsModalUpdate: true });
          },
        })
      ),
    };
  }

  //  If our modal is open and our props update, we need to also update
  //  the modal.
  handleUpdate = () => {
    const { onModalOpen } = this.props;
    const { needsModalUpdate } = this.state;

    //  Gets our modal object.
    const modal = this.handleMakeModal();

    //  Reopens the modal with the new object.
    if (needsModalUpdate && modal && onModalOpen) {
      onModalOpen(modal);
    }
  }

  //  Updates our modal as necessary.
  componentDidUpdate (prevProps) {
    const { items } = this.props;
    const { needsModalUpdate } = this.state;
    if (needsModalUpdate && items.find(
      (item, i) => item.on !== prevProps.items[i].on
    )) {
      this.handleUpdate();
      this.setState({ needsModalUpdate: false });
    }
  }

  //  Rendering.
  render () {
    const {
      active,
      disabled,
      title,
      icon,
      items,
      onChange,
      value,
    } = this.props;
    const { open, placement } = this.state;
    const computedClass = classNames('composer--options--dropdown', {
      active,
      open,
      top: placement === 'top',
    });

    //  The result.
    return (
      <div
        className={computedClass}
        onKeyDown={this.handleKeyDown}
      >
        <IconButton
          active={open || active}
          className='value'
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
        <Overlay
          containerPadding={20}
          placement={placement}
          show={open}
          target={this}
        >
          <DropdownMenu
            items={items}
            onChange={onChange}
            onClose={this.handleClose}
            value={value}
            openedViaKeyboard={this.state.openedViaKeyboard}
          />
        </Overlay>
      </div>
    );
  }

}

//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';
import Overlay from 'react-overlays/lib/Overlay';

//  Components.
import IconButton from 'flavours/glitch/components/icon_button';
import ComposerOptionsDropdownContent from './content';

//  Utils.
import { isUserTouching } from 'flavours/glitch/util/is_mobile';
import { assignHandlers } from 'flavours/glitch/util/react_helpers';

//  Handlers.
const handlers = {

  //  Closes the dropdown.
  handleClose () {
    this.setState({ open: false });
  },

  //  The enter key toggles the dropdown's open state, and the escape
  //  key closes it.
  handleKeyDown ({ key }) {
    const {
      handleClose,
      handleToggle,
    } = this.handlers;
    switch (key) {
    case 'Enter':
      handleToggle(key);
      break;
    case 'Escape':
      handleClose();
      break;
    }
  },

  //  Creates an action modal object.
  handleMakeModal () {
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
  },

  //  Toggles opening and closing the dropdown.
  handleToggle ({ target }) {
    const { handleMakeModal } = this.handlers;
    const { onModalOpen } = this.props;
    const { open } = this.state;

    //  If this is a touch device, we open a modal instead of the
    //  dropdown.
    if (isUserTouching()) {

      //  This gets the modal to open.
      const modal = handleMakeModal();

      //  If we can, we then open the modal.
      if (modal && onModalOpen) {
        onModalOpen(modal);
        return;
      }
    }

    const { top } = target.getBoundingClientRect();
    this.setState({ placement: top * 2 < innerHeight ? 'bottom' : 'top' });
    //  Otherwise, we just set our state to open.
    this.setState({ open: !open });
  },

  //  If our modal is open and our props update, we need to also update
  //  the modal.
  handleUpdate () {
    const { handleMakeModal } = this.handlers;
    const { onModalOpen } = this.props;
    const { needsModalUpdate } = this.state;

    //  Gets our modal object.
    const modal = handleMakeModal();

    //  Reopens the modal with the new object.
    if (needsModalUpdate && modal && onModalOpen) {
      onModalOpen(modal);
    }
  },
};

//  The component.
export default class ComposerOptionsDropdown extends React.PureComponent {

  //  Constructor.
  constructor (props) {
    super(props);
    assignHandlers(this, handlers);
    this.state = {
      needsModalUpdate: false,
      open: false,
      placement: 'bottom',
    };
  }

  //  Updates our modal as necessary.
  componentDidUpdate (prevProps) {
    const { handleUpdate } = this.handlers;
    const { items } = this.props;
    const { needsModalUpdate } = this.state;
    if (needsModalUpdate && items.find(
      (item, i) => item.on !== prevProps.items[i].on
    )) {
      handleUpdate();
      this.setState({ needsModalUpdate: false });
    }
  }

  //  Rendering.
  render () {
    const {
      handleClose,
      handleKeyDown,
      handleToggle,
    } = this.handlers;
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
        onKeyDown={handleKeyDown}
      >
        <IconButton
          active={open || active}
          className='value'
          disabled={disabled}
          icon={icon}
          onClick={handleToggle}
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
          <ComposerOptionsDropdownContent
            items={items}
            onChange={onChange}
            onClose={handleClose}
            value={value}
          />
        </Overlay>
      </div>
    );
  }

}

//  Props.
ComposerOptionsDropdown.propTypes = {
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
  onChange: PropTypes.func,
  onModalClose: PropTypes.func,
  onModalOpen: PropTypes.func,
  title: PropTypes.string,
  value: PropTypes.string,
};

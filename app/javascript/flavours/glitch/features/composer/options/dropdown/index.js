//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';
import spring from 'react-motion/lib/spring';
import Overlay from 'react-overlays/lib/Overlay';

//  Components.
import IconButton from 'flavours/glitch/components/icon_button';
import ComposerOptionsDropdownItem from './item';

//  Utils.
import { withPassive } from 'flavours/glitch/util/dom_helpers';
import { isUserTouching } from 'flavours/glitch/util/is_mobile';
import Motion from 'flavours/glitch/util/optional_motion';
import { assignHandlers } from 'flavours/glitch/util/react_helpers';

//  We'll use this to define our various transitions.
const springMotion = spring(1, {
  damping: 35,
  stiffness: 400,
});

//  Handlers.
const handlers = {

  //  Closes the dropdown.
  close () {
    this.setState({ open: false });
  },

  //  When the document is clicked elsewhere, we close the dropdown.
  documentClick ({ target }) {
    const { node } = this;
    const { onClose } = this.props;
    if (onClose && node && !node.contains(target)) {
      onClose();
    }
  },

  //  The enter key toggles the dropdown's open state, and the escape
  //  key closes it.
  keyDown ({ key }) {
    const {
      close,
      toggle,
    } = this.handlers;
    switch (key) {
    case 'Enter':
      toggle();
      break;
    case 'Escape':
      close();
      break;
    }
  },

  //  Toggles opening and closing the dropdown.
  toggle () {
    const {
      items,
      onChange,
      onModalClose,
      onModalOpen,
      value,
    } = this.props;
    const { open } = this.state;

    //  If this is a touch device, we open a modal instead of the
    //  dropdown.
    if (onModalClose && isUserTouching()) {
      if (open) {
        onModalClose();
      } else if (onChange && onModalOpen) {
        onModalOpen({
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
              },
            })
          ),
        });
      }

    //  Otherwise, we just set our state to open.
    } else {
      this.setState({ open: !open });
    }
  },

  //  Stores our node in `this.node`.
  ref (node) {
    this.node = node;
  },
};

//  The component.
export default class ComposerOptionsDropdown extends React.PureComponent {

  //  Constructor.
  constructor (props) {
    super(props);
    assignHandlers(this, handlers);
    this.state = { open: false };

    //  Instance variables.
    this.node = null;
  }

  //  On mounting, we add our listeners.
  componentDidMount () {
    const { documentClick } = this.handlers;
    document.addEventListener('click', documentClick, false);
    document.addEventListener('touchend', documentClick, withPassive);
  }

  //  On unmounting, we remove our listeners.
  componentWillUnmount () {
    const { documentClick } = this.handlers;
    document.removeEventListener('click', documentClick, false);
    document.removeEventListener('touchend', documentClick, withPassive);
  }

  //  Rendering.
  render () {
    const {
      close,
      keyDown,
      ref,
      toggle,
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
    const { open } = this.state;
    const computedClass = classNames('composer--options--dropdown', {
      active,
      open: open || active,
    });

    //  The result.
    return (
      <div
        className={computedClass}
        onKeyDown={keyDown}
        ref={ref}
      >
        <IconButton
          active={open || active}
          className='value'
          disabled={disabled}
          icon={icon}
          onClick={toggle}
          size={18}
          style={{
            height: null,
            lineHeight: '27px',
          }}
          title={title}
        />
        <Overlay
          placement='bottom'
          show={open}
          target={this}
        >
          <Motion
            defaultStyle={{
              opacity: 0,
              scaleX: 0.85,
              scaleY: 0.75,
            }}
            style={{
              opacity: springMotion,
              scaleX: springMotion,
              scaleY: springMotion,
            }}
          >
            {({ opacity, scaleX, scaleY }) => (
              <div
                className='composer--options--dropdown__dropdown'
                ref={this.setRef}
                style={{
                  opacity: opacity,
                  transform: `scale(${scaleX}, ${scaleY})`,
                }}
              >
                {items.map(
                  ({
                    name,
                    ...rest
                  }) => (
                    <ComposerOptionsDropdownItem
                      active={name === value}
                      key={name}
                      name={name}
                      onChange={onChange}
                      onClose={close}
                      options={rest}
                    />
                  )
                )}
              </div>
            )}
          </Motion>
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

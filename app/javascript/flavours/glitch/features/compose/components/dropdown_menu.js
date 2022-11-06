//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import spring from 'react-motion/lib/spring';
import ImmutablePureComponent from 'react-immutable-pure-component';
import classNames from 'classnames';

//  Components.
import Icon from 'flavours/glitch/components/icon';

//  Utils.
import { withPassive } from 'flavours/glitch/utils/dom_helpers';
import Motion from '../../ui/util/optional_motion';
import { assignHandlers } from 'flavours/glitch/utils/react_helpers';

//  The spring to use with our motion.
const springMotion = spring(1, {
  damping: 35,
  stiffness: 400,
});

//  The component.
export default class ComposerOptionsDropdownContent extends React.PureComponent {

  static propTypes = {
    items: PropTypes.arrayOf(PropTypes.shape({
      icon: PropTypes.string,
      meta: PropTypes.node,
      name: PropTypes.string.isRequired,
      text: PropTypes.node,
    })),
    onChange: PropTypes.func.isRequired,
    onClose: PropTypes.func.isRequired,
    style: PropTypes.object,
    value: PropTypes.string,
    renderItemContents: PropTypes.func,
    openedViaKeyboard: PropTypes.bool,
    closeOnChange: PropTypes.bool,
  };

  static defaultProps = {
    style: {},
    closeOnChange: true,
  };

  state = {
    mounted: false,
    value: this.props.openedViaKeyboard ? this.props.items[0].name : undefined,
  };

  //  When the document is clicked elsewhere, we close the dropdown.
  handleDocumentClick = (e) => {
    if (this.node && !this.node.contains(e.target)) {
      this.props.onClose();
    }
  }

  //  Stores our node in `this.node`.
  handleRef = (node) => {
    this.node = node;
  }

  //  On mounting, we add our listeners.
  componentDidMount () {
    document.addEventListener('click', this.handleDocumentClick, false);
    document.addEventListener('touchend', this.handleDocumentClick, withPassive);
    if (this.focusedItem) {
      this.focusedItem.focus({ preventScroll: true });
    } else {
      this.node.firstChild.focus({ preventScroll: true });
    }
    this.setState({ mounted: true });
  }

  //  On unmounting, we remove our listeners.
  componentWillUnmount () {
    document.removeEventListener('click', this.handleDocumentClick, false);
    document.removeEventListener('touchend', this.handleDocumentClick, withPassive);
  }

  handleClick = (e) => {
    const i = Number(e.currentTarget.getAttribute('data-index'));

    const {
      onChange,
      onClose,
      closeOnChange,
      items,
    } = this.props;

    const { name } = this.props.items[i];
    e.preventDefault();  //  Prevents change in focus on click
    if (closeOnChange) {
      onClose();
    }
    onChange(name);
  }

  // Handle changes differently whether the dropdown is a list of options or actions
  handleChange = (name) => {
    if (this.props.value) {
      this.props.onChange(name);
    } else {
      this.setState({ value: name });
    }
  }

  handleKeyDown = (e) => {
    const index = Number(e.currentTarget.getAttribute('data-index'));
    const { items } = this.props;
    let element = null;

    switch(e.key) {
    case 'Escape':
      this.props.onClose();
      break;
    case 'Enter':
    case ' ':
      this.handleClick(e);
      break;
    case 'ArrowDown':
      element = this.node.childNodes[index + 1] || this.node.firstChild;
      break;
    case 'ArrowUp':
      element = this.node.childNodes[index - 1] || this.node.lastChild;
      break;
    case 'Tab':
      if (e.shiftKey) {
        element = this.node.childNodes[index - 1] || this.node.lastChild;
      } else {
        element = this.node.childNodes[index + 1] || this.node.firstChild;
      }
      break;
    case 'Home':
      element = this.node.firstChild;
      break;
    case 'End':
      element = this.node.lastChild;
      break;
    }

    if (element) {
      element.focus();
      this.handleChange(this.props.items[Number(element.getAttribute('data-index'))].name);
      e.preventDefault();
      e.stopPropagation();
    }
  }

  setFocusRef = c => {
    this.focusedItem = c;
  }

  renderItem = (item, i) => {
    const { name, icon, meta, text } = item;

    const active = (name === (this.props.value || this.state.value));

    const computedClass = classNames('privacy-dropdown__option', { active });

    let contents = this.props.renderItemContents && this.props.renderItemContents(item, i);

    if (!contents) {
      contents = (
        <React.Fragment>
          {icon && <Icon className='icon' fixedWidth id={icon} />}

          <div className='privacy-dropdown__option__content'>
            <strong>{text}</strong>
            {meta}
          </div>
        </React.Fragment>
      );
    }

    return (
      <div
        className={computedClass}
        onClick={this.handleClick}
        onKeyDown={this.handleKeyDown}
        role='option'
        tabIndex='0'
        key={name}
        data-index={i}
        ref={active ? this.setFocusRef : null}
      >
        {contents}
      </div>
    );
  }

  //  Rendering.
  render () {
    const { mounted } = this.state;
    const {
      items,
      onChange,
      onClose,
      style,
    } = this.props;

    //  The result.
    return (
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
          // It should not be transformed when mounting because the resulting
          // size will be used to determine the coordinate of the menu by
          // react-overlays
          <div
            className='privacy-dropdown__dropdown'
            ref={this.handleRef}
            role='listbox'
            style={{
              ...style,
              opacity: opacity,
              transform: mounted ? `scale(${scaleX}, ${scaleY})` : null,
            }}
          >
            {!!items && items.map((item, i) => this.renderItem(item, i))}
          </div>
        )}
      </Motion>
    );
  }

}

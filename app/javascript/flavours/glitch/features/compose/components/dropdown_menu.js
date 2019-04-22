//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import spring from 'react-motion/lib/spring';
import Toggle from 'react-toggle';
import ImmutablePureComponent from 'react-immutable-pure-component';
import classNames from 'classnames';

//  Components.
import Icon from 'flavours/glitch/components/icon';

//  Utils.
import { withPassive } from 'flavours/glitch/util/dom_helpers';
import Motion from 'flavours/glitch/util/optional_motion';
import { assignHandlers } from 'flavours/glitch/util/react_helpers';

class ComposerOptionsDropdownContentItem extends ImmutablePureComponent {

  static propTypes = {
    active: PropTypes.bool,
    name: PropTypes.string,
    onChange: PropTypes.func,
    onClose: PropTypes.func,
    options: PropTypes.shape({
      icon: PropTypes.string,
      meta: PropTypes.node,
      on: PropTypes.bool,
      text: PropTypes.node,
    }),
  };

  handleActivate = (e) => {
    const {
      name,
      onChange,
      onClose,
      options: { on },
    } = this.props;

    //  If the escape key was pressed, we close the dropdown.
    if (e.key === 'Escape' && onClose) {
      onClose();

    //  Otherwise, we both close the dropdown and change the value.
    } else if (onChange && (!e.key || e.key === 'Enter')) {
      e.preventDefault();  //  Prevents change in focus on click
      if ((on === null || typeof on === 'undefined') && onClose) {
        onClose();
      }
      onChange(name);
    }
  }

  //  Rendering.
  render () {
    const {
      active,
      options: {
        icon,
        meta,
        on,
        text,
      },
    } = this.props;
    const computedClass = classNames('composer--options--dropdown--content--item', {
      active,
      lengthy: meta,
      'toggled-off': !on && on !== null && typeof on !== 'undefined',
      'toggled-on': on,
      'with-icon': icon,
    });

    let prefix = null;

    if (on !== null && typeof on !== 'undefined') {
      prefix = <Toggle checked={on} onChange={this.handleActivate} />;
    } else if (icon) {
      prefix = <Icon className='icon' fullwidth icon={icon} />
    }

    //  The result.
    return (
      <div
        className={computedClass}
        onClick={this.handleActivate}
        onKeyDown={this.handleActivate}
        role='button'
        tabIndex='0'
      >
        {prefix}

        <div className='content'>
          <strong>{text}</strong>
          {meta}
        </div>
      </div>
    );
  }

};

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
      on: PropTypes.bool,
      text: PropTypes.node,
    })),
    onChange: PropTypes.func,
    onClose: PropTypes.func,
    style: PropTypes.object,
    value: PropTypes.string,
  };

  static defaultProps = {
    style: {},
  };

  state = {
    mounted: false,
  };

  //  When the document is clicked elsewhere, we close the dropdown.
  handleDocumentClick = ({ target }) => {
    const { node } = this;
    const { onClose } = this.props;
    if (onClose && node && !node.contains(target)) {
      onClose();
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
    this.setState({ mounted: true });
  }

  //  On unmounting, we remove our listeners.
  componentWillUnmount () {
    document.removeEventListener('click', this.handleDocumentClick, false);
    document.removeEventListener('touchend', this.handleDocumentClick, withPassive);
  }

  //  Rendering.
  render () {
    const { mounted } = this.state;
    const {
      items,
      onChange,
      onClose,
      style,
      value,
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
            className='composer--options--dropdown--content'
            ref={this.handleRef}
            style={{
              ...style,
              opacity: opacity,
              transform: mounted ? `scale(${scaleX}, ${scaleY})` : null,
            }}
          >
            {items ? items.map(
              ({
                name,
                ...rest
              }) => (
                <ComposerOptionsDropdownContentItem
                  active={name === value}
                  key={name}
                  name={name}
                  onChange={onChange}
                  onClose={onClose}
                  options={rest}
                />
              )
            ) : null}
          </div>
        )}
      </Motion>
    );
  }

}

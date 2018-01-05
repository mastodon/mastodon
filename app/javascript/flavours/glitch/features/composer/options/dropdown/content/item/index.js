//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';
import Toggle from 'react-toggle';

//  Components.
import Icon from 'flavours/glitch/components/icon';

//  Utils.
import { assignHandlers } from 'flavours/glitch/util/react_helpers';

//  Handlers.
const handlers = {

  //  This function activates the dropdown item.
  handleActivate (e) {
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
  },
};

//  The component.
export default class ComposerOptionsDropdownContentItem extends React.PureComponent {

  //  Constructor.
  constructor (props) {
    super(props);
    assignHandlers(this, handlers);
  }

  //  Rendering.
  render () {
    const { handleActivate } = this.handlers;
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

    //  The result.
    return (
      <div
        className={computedClass}
        onClick={handleActivate}
        onKeyDown={handleActivate}
        role='button'
        tabIndex='0'
      >
        {function () {

          //  We render a `<Toggle>` if we were provided an `on`
          //  property, and otherwise show an `<Icon>` if available.
          switch (true) {
          case on !== null && typeof on !== 'undefined':
            return (
              <Toggle
                checked={on}
                onChange={handleActivate}
              />
            );
          case !!icon:
            return (
              <Icon
                className='icon'
                fullwidth
                icon={icon}
              />
            );
          default:
            return null;
          }
        }()}
        {meta ? (
          <div className='content'>
            <strong>{text}</strong>
            {meta}
          </div>
        ) : <div className='content'>{text}</div>}
      </div>
    );
  }

};

//  Props.
ComposerOptionsDropdownContentItem.propTypes = {
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

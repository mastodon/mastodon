//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';
import {
  FormattedMessage,
  defineMessages,
} from 'react-intl';
import Overlay from 'react-overlays/lib/Overlay';

//  Components.
import Icon from 'flavours/glitch/components/icon';
import DrawerSearchPopout from './popout';

//  Utils.
import { focusRoot } from 'flavours/glitch/util/dom_helpers';
import {
  assignHandlers,
  hiddenComponent,
} from 'flavours/glitch/util/react_helpers';

//  Messages.
const messages = defineMessages({
  placeholder: {
    defaultMessage: 'Search',
    id: 'search.placeholder',
  },
});

//  Handlers.
const handlers = {

  blur () {
    this.setState({ expanded: false });
  },

  change ({ target: { value } }) {
    const { onChange } = this.props;
    if (onChange) {
      onChange(value);
    }
  },

  clear (e) {
    const {
      onClear,
      submitted,
      value: { length },
    } = this.props;
    e.preventDefault();  //  Prevents focus change ??
    if (onClear && (submitted || length)) {
      onClear();
    }
  },

  focus () {
    const { onShow } = this.props;
    this.setState({ expanded: true });
    if (onShow) {
      onShow();
    }
  },

  keyUp (e) {
    const { onSubmit } = this.props;
    switch (e.key) {
    case 'Enter':
      if (onSubmit) {
        onSubmit();
      }
      break;
    case 'Escape':
      focusRoot();
    }
  },
};

//  The component.
export default class DrawerSearch extends React.PureComponent {

  constructor (props) {
    super(props);
    assignHandlers(this, handlers);
    this.state = { expanded: false };
  }

  render () {
    const {
      blur,
      change,
      clear,
      focus,
      keyUp,
    } = this.handlers;
    const {
      intl,
      submitted,
      value,
    } = this.props;
    const { expanded } = this.state;
    const computedClass = classNames('drawer--search', { active: value.length || submitted });

    return (
      <div className={computedClass}>
        <label>
          <span {...hiddenComponent}>
            <FormattedMessage {...messages.placeholder} />
          </span>
          <input
            type='text'
            placeholder={intl.formatMessage(messages.placeholder)}
            value={value}
            onChange={change}
            onKeyUp={keyUp}
            onFocus={focus}
            onBlur={blur}
          />
        </label>
        <div
          aria-label={intl.formatMessage(messages.placeholder)}
          className='icon'
          onClick={clear}
          role='button'
          tabIndex='0'
        >
          <Icon icon='search' />
          <Icon icon='fa-times-circle' />
        </div>

        <Overlay
          placement='bottom'
          show={expanded && !value.length && !submitted}
          target={this}
        ><DrawerSearchPopout /></Overlay>
      </div>
    );
  }

}

DrawerSearch.propTypes = {
  value: PropTypes.string,
  submitted: PropTypes.bool,
  onChange: PropTypes.func,
  onSubmit: PropTypes.func,
  onClear: PropTypes.func,
  onShow: PropTypes.func,
  intl: PropTypes.object,
};

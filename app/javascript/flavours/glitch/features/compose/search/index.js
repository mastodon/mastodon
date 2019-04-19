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

  handleBlur () {
    this.setState({ expanded: false });
  },

  handleChange ({ target: { value } }) {
    const { onChange } = this.props;
    if (onChange) {
      onChange(value);
    }
  },

  handleClear (e) {
    const {
      onClear,
      submitted,
      value,
    } = this.props;
    e.preventDefault();  //  Prevents focus change ??
    if (onClear && (submitted || value && value.length)) {
      onClear();
    }
  },

  handleFocus () {
    const { onShow } = this.props;
    this.setState({ expanded: true });
    if (onShow) {
      onShow();
    }
  },

  handleKeyUp (e) {
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

  //  Constructor.
  constructor (props) {
    super(props);
    assignHandlers(this, handlers);
    this.state = { expanded: false };
  }

  //  Rendering.
  render () {
    const {
      handleBlur,
      handleChange,
      handleClear,
      handleFocus,
      handleKeyUp,
    } = this.handlers;
    const {
      intl,
      submitted,
      value,
    } = this.props;
    const { expanded } = this.state;
    const active = value && value.length || submitted;
    const computedClass = classNames('drawer--search', { active });

    return (
      <div className={computedClass}>
        <label>
          <span {...hiddenComponent}>
            <FormattedMessage {...messages.placeholder} />
          </span>
          <input
            type='text'
            placeholder={intl.formatMessage(messages.placeholder)}
            value={value || ''}
            onChange={handleChange}
            onKeyUp={handleKeyUp}
            onFocus={handleFocus}
            onBlur={handleBlur}
          />
        </label>
        <div
          aria-label={intl.formatMessage(messages.placeholder)}
          className='icon'
          onClick={handleClear}
          role='button'
          tabIndex='0'
        >
          <Icon icon='search' />
          <Icon icon='times-circle' />
        </div>
        <Overlay
          placement='bottom'
          show={expanded && !active}
          target={this}
        ><DrawerSearchPopout /></Overlay>
      </div>
    );
  }

}

//  Props.
DrawerSearch.propTypes = {
  value: PropTypes.string,
  submitted: PropTypes.bool,
  onChange: PropTypes.func,
  onSubmit: PropTypes.func,
  onClear: PropTypes.func,
  onShow: PropTypes.func,
  intl: PropTypes.object,
};

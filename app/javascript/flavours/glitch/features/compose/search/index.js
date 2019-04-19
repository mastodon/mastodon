//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';
import { connect } from 'react-redux';
import {
  injectIntl,
  defineMessages,
} from 'react-intl';
import Overlay from 'react-overlays/lib/Overlay';

//  Components.
import Icon from 'flavours/glitch/components/icon';
import DrawerSearchPopout from './popout';

//  Utils.
import { focusRoot } from 'flavours/glitch/util/dom_helpers';

//  Messages.
const messages = defineMessages({
  placeholder: {
    defaultMessage: 'Search',
    id: 'search.placeholder',
  },
});

//  The component.
export default @injectIntl
class DrawerSearch extends React.PureComponent {

  static propTypes = {
    value: PropTypes.string.isRequired,
    submitted: PropTypes.bool,
    onChange: PropTypes.func.isRequired,
    onSubmit: PropTypes.func.isRequired,
    onClear: PropTypes.func.isRequired,
    onShow: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    expanded: false,
  };

  handleChange = (e) => {
    const { onChange } = this.props;
    if (onChange) {
      onChange(e.target.value);
    }
  }

  handleClear = (e) => {
    const {
      onClear,
      submitted,
      value,
    } = this.props;
    e.preventDefault();  //  Prevents focus change ??
    if (onClear && (submitted || value && value.length)) {
      onClear();
    }
  }

  handleBlur () {
    this.setState({ expanded: false });
  }

  handleFocus = () => {
    const { onShow } = this.props;
    this.setState({ expanded: true });
    if (onShow) {
      onShow();
    }
  }

  handleKeyUp = (e) => {
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
  }

  render () {
    const { intl, value, submitted } = this.props;
    const { expanded } = this.state;
    const active = value.length > 0 || submitted;
    const computedClass = classNames('drawer--search', { active });

    return (
      <div className={computedClass}>
        <label>
          <span style={{ display: 'none' }}>{intl.formatMessage(messages.placeholder)}</span>
          <input
            type='text'
            placeholder={intl.formatMessage(messages.placeholder)}
            value={value || ''}
            onChange={this.handleChange}
            onKeyUp={this.handleKeyUp}
            onFocus={this.handleFocus}
            onBlur={this.handleBlur}
          />
        </label>
        <div
          aria-label={intl.formatMessage(messages.placeholder)}
          className='icon'
          onClick={this.handleClear}
          role='button'
          tabIndex='0'
        >
          <Icon icon='search' />
          <Icon icon='times-circle' />
        </div>
        <Overlay show={expanded && !active} placement='bottom' target={this}>
          <DrawerSearchPopout />
        </Overlay>
      </div>
    );
  }

}

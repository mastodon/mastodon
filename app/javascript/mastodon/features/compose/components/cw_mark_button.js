/**
 * This file substitude `text_icon_button.js`
 * @ mashiro
 */
import React from 'react';
import PropTypes from 'prop-types';
import IconButton from '../../../components/icon_button';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  marked: { id: 'compose_form.spoiler.marked', defaultMessage: 'Text is hidden behind warning' },
  unmarked: { id: 'compose_form.spoiler.unmarked', defaultMessage: 'Text is not hidden' },
});

const iconStyle = {
  height: null,
  lineHeight: '27px',
};

export default 
@injectIntl
class CwMarkIconButton extends React.PureComponent {

  static propTypes = {
    active: PropTypes.bool,
    onClick: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    disabled: PropTypes.bool,
  };

  handleClick = (e) => {
    e.preventDefault();
    this.props.onClick();
  }

  render () {
    const { intl, disabled, active } = this.props;

    return (
      <div className='compose-form__poll-button'>
      <IconButton
        icon='theater-masks'
        title={intl.formatMessage(active ? messages.marked : messages.unmarked)}
        disabled={disabled}
        onClick={this.handleClick}
        className={`compose-form__poll-button-icon ${active ? 'active' : ''}`}
        size={18}
        inverted
        style={iconStyle}
      />
    </div>
    );
  }

}

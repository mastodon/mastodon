import React from 'react';
import IconButton from '../../../components/icon_button';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  to_crossbell: { id: 'crossbell_button.to_crossbell', defaultMessage: 'Also post to Crossbell' },
  not_to_crossbell: { id: 'crossbell_button.not_to_crossbell', defaultMessage: 'Don\'t post to Crossbell' },
});

const iconStyle = {
  height: null,
  lineHeight: '27px',
};

export default
@injectIntl
class CrossbellButton extends React.PureComponent {

  static propTypes = {
    disabled: PropTypes.bool,
    unavailable: PropTypes.bool,
    active: PropTypes.bool,
    onClick: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleClick = () => {
    this.props.onClick();
  }

  render () {
    const { intl, active, unavailable, disabled } = this.props;

    if (unavailable) {
      return null;
    }

    return (
      <div className='compose-form__crossbell-button'>
        <IconButton
          icon='bell'
          title={intl.formatMessage(active ? messages.not_to_crossbell : messages.to_crossbell)}
          disabled={disabled}
          onClick={this.handleClick}
          className={`compose-form__crossbell-button-icon ${active ? 'active' : ''}`}
          size={18}
          inverted
          style={iconStyle}
        />
      </div>
    );
  }

}

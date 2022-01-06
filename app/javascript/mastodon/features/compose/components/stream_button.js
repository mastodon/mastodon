import React from 'react';
import IconButton from '../../../components/icon_button';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  add_stream: { id: 'stream_button.add_stream', defaultMessage: 'Create a stream' },
  remove_stream: { id: 'stream_button.remove_stream', defaultMessage: 'Cancel streaming' },
});

const iconStyle = {
  height: null,
  lineHeight: '27px',
};

export default
@injectIntl
class StreamButton extends React.PureComponent {

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
      <div className='stream compose-form__poll-button'>
        <IconButton
          icon='podcast'
          title={intl.formatMessage(active ? messages.remove_stream : messages.add_stream)}
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

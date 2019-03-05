import React from 'react';
import IconButton from '../../../components/icon_button';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';

const messages = defineMessages({
  add_poll: { id: 'poll_button.add_poll', defaultMessage: 'Turn this toot into a poll' },
  remove_poll: { id: 'poll_button.remove_poll', defaultMessage: 'Remove the poll from this toot' },
});

const iconStyle = {
  height: null,
  lineHeight: '27px',
};

export default
@injectIntl
class PollButton extends ImmutablePureComponent {

  static propTypes = {
    disabled: PropTypes.bool,
    active: PropTypes.bool,
    onClick: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleClick = () => {
    this.props.onClick();
  }

  render () {
    const { intl, active, disabled } = this.props;

    return (
      <div className='compose-form__poll-button'>
        <IconButton
          icon='tasks'
          title={intl.formatMessage(active ? messages.remove_poll : messages.add_poll)}
          disabled={disabled}
          onClick={this.handleClick}
          className={`compose-form__poll-button-icon ${active ? 'active' : ''}`}
          size={18}
          inverted
          style={iconStyle} />
      </div>
    );
  }

}

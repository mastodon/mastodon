import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, injectIntl } from 'react-intl';

import BarChart4BarsIcon from '@/material-icons/400-20px/bar_chart_4_bars.svg?react';

import { IconButton } from '../../../components/icon_button';

const messages = defineMessages({
  add_poll: { id: 'poll_button.add_poll', defaultMessage: 'Add a poll' },
  remove_poll: { id: 'poll_button.remove_poll', defaultMessage: 'Remove poll' },
});

const iconStyle = {
  height: null,
  lineHeight: '27px',
};

class PollButton extends PureComponent {

  static propTypes = {
    disabled: PropTypes.bool,
    active: PropTypes.bool,
    onClick: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleClick = () => {
    this.props.onClick();
  };

  render () {
    const { intl, active, disabled } = this.props;

    return (
      <div className='compose-form__poll-button'>
        <IconButton
          icon='tasks'
          iconComponent={BarChart4BarsIcon}
          title={intl.formatMessage(active ? messages.remove_poll : messages.add_poll)}
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

export default injectIntl(PollButton);

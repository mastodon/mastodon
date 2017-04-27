import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  clear: { id: 'notifications.clear', defaultMessage: 'Clear notifications' }
});

class ClearColumnButton extends React.Component {

  render () {
    const { intl } = this.props;

    return (
      <div role='button' title={intl.formatMessage(messages.clear)} className='column-icon column-icon-clear' tabIndex='0' onClick={this.props.onClick}>
        <i className='fa fa-eraser' />
      </div>
    );
  }
}

ClearColumnButton.propTypes = {
  onClick: PropTypes.func.isRequired,
  intl: PropTypes.object.isRequired
};

export default injectIntl(ClearColumnButton);

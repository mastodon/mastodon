import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  clear: { id: 'notifications.clear', defaultMessage: 'Clear notifications' }
});

const ClearColumnButton = React.createClass({

  propTypes: {
    onClick: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired
  },

  render () {
    const { intl } = this.props;

    return (
      <div role='button' title={intl.formatMessage(messages.clear)} className='column-icon column-icon-clear' tabIndex='0' onClick={this.props.onClick}>
        <i className='fa fa-eraser' />
      </div>
    );
  }
})

export default injectIntl(ClearColumnButton);

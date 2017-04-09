import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  clear: { id: 'notifications.clear', defaultMessage: 'Clear notifications' }
});

const iconStyle = {
  fontSize: '16px',
  padding: '15px',
  position: 'absolute',
  right: '48px',
  top: '0',
  cursor: 'pointer',
  zIndex: '2'
};

const ClearColumnButton = React.createClass({

  propTypes: {
    onClick: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired
  },

  render () {
    const { intl } = this.props;

    return (
      <div title={intl.formatMessage(messages.clear)} className='column-icon' tabIndex='0' style={iconStyle} onClick={this.props.onClick}>
        <i className='fa fa-eraser' />
      </div>
    );
  }
})

export default injectIntl(ClearColumnButton);

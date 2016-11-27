import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Avatar from '../../../components/avatar';
import IconButton from '../../../components/icon_button';
import DisplayName from '../../../components/display_name';
import emojify from '../../../emoji';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  cancel: { id: 'reply_indicator.cancel', defaultMessage: 'Cancel' }
});

const PrivateMessageIndicator = React.createClass({

  contextTypes: {
    router: React.PropTypes.object
  },

  propTypes: {
    recipient: ImmutablePropTypes.map.isRequired,
    onCancel: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  handleClick () {
    this.props.onCancel();
  },

  handleAccountClick (e) {
    if (e.button === 0) {
      e.preventDefault();
      this.context.router.push(`/accounts/${this.props.recipient.get('id')}`);
    }
  },

  render () {
    const { intl } = this.props;

    return (
      <div style={{ background: '#c8ae9b', padding: '10px' }}>
        <div style={{ overflow: 'hidden', marginBottom: '5px' }}>
          <div style={{ float: 'right', lineHeight: '24px' }}><IconButton title={intl.formatMessage(messages.cancel)} icon='times' onClick={this.handleClick} /></div>

          <a href={this.props.recipient.get('url')} onClick={this.handleAccountClick} className='reply-indicator__display-name' style={{ display: 'block', maxWidth: '100%', paddingRight: '25px', color: '#282c37', textDecoration: 'none', overflow: 'hidden', lineHeight: '24px' }}>
            <div style={{ float: 'left', marginRight: '5px' }}><Avatar size={24} src={this.props.recipient.get('avatar')} /></div>
            <DisplayName account={this.props.recipient} />
          </a>
        </div>

        <div className='reply-indicator__content'>
          <p style={{ fontStyle: 'italic' }}>This message will be visible to you, the recipient, and instance administrators.</p>
        </div>
      </div>
    );
  }

});

export default injectIntl(PrivateMessageIndicator);
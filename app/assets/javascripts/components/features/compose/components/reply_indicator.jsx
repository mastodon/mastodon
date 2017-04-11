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

const ReplyIndicator = React.createClass({

  contextTypes: {
    router: React.PropTypes.object
  },

  propTypes: {
    status: ImmutablePropTypes.map,
    onCancel: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired
  },

  mixins: [PureRenderMixin],

  handleClick () {
    this.props.onCancel();
  },

  handleAccountClick (e) {
    if (e.button === 0) {
      e.preventDefault();
      this.context.router.push(`/accounts/${this.props.status.getIn(['account', 'id'])}`);
    }
  },

  render () {
    const { status, intl } = this.props;

    if (!status) {
      return null;
    }

    const content  = { __html: emojify(status.get('content')) };

    return (
      <div className='reply-indicator'>
        <div style={{ overflow: 'hidden', marginBottom: '5px' }}>
          <div style={{ float: 'right', lineHeight: '24px' }}><IconButton title={intl.formatMessage(messages.cancel)} icon='times' onClick={this.handleClick} /></div>

          <a href={status.getIn(['account', 'url'])} onClick={this.handleAccountClick} className='reply-indicator__display-name' style={{ display: 'block', maxWidth: '100%', paddingRight: '25px', textDecoration: 'none', overflow: 'hidden', lineHeight: '24px' }}>
            <div style={{ float: 'left', marginRight: '5px' }}><Avatar size={24} src={status.getIn(['account', 'avatar'])} staticSrc={status.getIn(['account', 'avatar_static'])} /></div>
            <DisplayName account={status.get('account')} />
          </a>
        </div>

        <div className='reply-indicator__content' dangerouslySetInnerHTML={content} />
      </div>
    );
  }

});

export default injectIntl(ReplyIndicator);

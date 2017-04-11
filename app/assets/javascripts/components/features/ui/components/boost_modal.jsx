import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl } from 'react-intl';
import IconButton from '../../../components/icon_button';
import Button from '../../../components/button';
import DetailedStatus from '../../status/components/detailed_status';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
  reblog: { id: 'status.reblog', defaultMessage: 'Boost' }
});

const closeStyle = {
  position: 'absolute',
  top: '4px',
  right: '4px'
};

const buttonContainerStyle = {
  textAlign: 'right',
  padding: '10px'
};

const BoostModal = React.createClass({

  propTypes: {
    status: ImmutablePropTypes.map.isRequired,
    onReblog: React.PropTypes.func.isRequired,
    onClose: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired
  },

  mixins: [PureRenderMixin],

  handleReblog() {
    this.props.onReblog(this.props.status);
    this.props.onClose();
  },

  handleOpenMedia() {
    // do nothing"
  },

  render () {
    const { status, intl, onClose } = this.props;

    const reblogButton = <span><i className='fa fa-retweet' /> {intl.formatMessage(messages.reblog)}</span>;

    return (
      <div className='modal-root__modal boost-modal'>
        <IconButton title={intl.formatMessage(messages.close)} icon='times' onClick={onClose} size={16} style={closeStyle} />
        <div>
          <DetailedStatus status={status} onOpenMedia={this.handleOpenMedia} />
        </div>
        <div style={buttonContainerStyle}>
          <Button text={reblogButton} onClick={this.handleReblog} />
        </div>
      </div>
    );
  }

});

export default injectIntl(BoostModal);

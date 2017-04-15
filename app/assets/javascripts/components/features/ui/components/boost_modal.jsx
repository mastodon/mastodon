import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import IconButton from '../../../components/icon_button';
import Button from '../../../components/button';
import StatusContent from '../../../components/status_content';
import Avatar from '../../../components/avatar';
import RelativeTimestamp from '../../../components/relative_timestamp';
import DisplayName from '../../../components/display_name';

const messages = defineMessages({
  reblog: { id: 'status.reblog', defaultMessage: 'Boost' }
});

const BoostModal = React.createClass({
  contextTypes: {
    router: React.PropTypes.object
  },

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

  handleAccountClick (e) {
    if (e.button === 0) {
      e.preventDefault();
      this.props.onClose();
      this.context.router.push(`/accounts/${this.props.status.getIn(['account', 'id'])}`);
    }
  },

  render () {
    const { status, intl, onClose } = this.props;

    return (
      <div className='modal-root__modal boost-modal'>
        <div className='boost-modal__container'>
          <div className='status light'>
            <div style={{ fontSize: '15px' }}>
              <div style={{ float: 'right', fontSize: '14px' }}>
                <a href={status.get('url')} className='status__relative-time' target='_blank' rel='noopener'><RelativeTimestamp timestamp={status.get('created_at')} /></a>
              </div>

              <a onClick={this.handleAccountClick} href={status.getIn(['account', 'url'])} className='status__display-name' style={{ display: 'block', maxWidth: '100%', paddingRight: '25px' }}>
                <div className='status__avatar' style={{ position: 'absolute', left: '10px', top: '10px', width: '48px', height: '48px' }}>
                  <Avatar src={status.getIn(['account', 'avatar'])} staticSrc={status.getIn(['account', 'avatar_static'])} size={48} />
                </div>

                <DisplayName account={status.get('account')} />
              </a>
            </div>

            <StatusContent status={status} />
          </div>
        </div>

        <div className='boost-modal__action-bar'>
          <div><FormattedMessage id='boost_modal.combo' defaultMessage='You can press {combo} to skip this next time' values={{ combo: <span>Shift + <i className='fa fa-retweet' /></span> }} /></div>
          <Button text={intl.formatMessage(messages.reblog)} onClick={this.handleReblog} />
        </div>
      </div>
    );
  }

});

export default injectIntl(BoostModal);

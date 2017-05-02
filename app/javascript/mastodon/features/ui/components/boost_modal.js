import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import IconButton from '../../../components/icon_button';
import Button from '../../../components/button';
import StatusContent from '../../../components/status_content';
import Avatar from '../../../components/avatar';
import RelativeTimestamp from '../../../components/relative_timestamp';
import DisplayName from '../../../components/display_name';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  reblog: { id: 'status.reblog', defaultMessage: 'Boost' }
});

class BoostModal extends ImmutablePureComponent {

  constructor (props, context) {
    super(props, context);
    this.handleReblog = this.handleReblog.bind(this);
    this.handleAccountClick = this.handleAccountClick.bind(this);
  }

  handleReblog() {
    this.props.onReblog(this.props.status);
    this.props.onClose();
  }

  handleAccountClick (e) {
    if (e.button === 0) {
      e.preventDefault();
      this.props.onClose();
      this.context.router.push(`/accounts/${this.props.status.getIn(['account', 'id'])}`);
    }
  }

  render () {
    const { status, intl, onClose } = this.props;

    return (
      <div className='modal-root__modal boost-modal'>
        <div className='boost-modal__container'>
          <div className='status light'>
            <div className='boost-modal__status-header'>
              <div className='boost-modal__status-time'>
                <a href={status.get('url')} className='status__relative-time' target='_blank' rel='noopener'><RelativeTimestamp timestamp={status.get('created_at')} /></a>
              </div>

              <a onClick={this.handleAccountClick} href={status.getIn(['account', 'url'])} className='status__display-name'>
                <div className='status__avatar'>
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

}

BoostModal.contextTypes = {
  router: PropTypes.object
};

BoostModal.propTypes = {
  status: ImmutablePropTypes.map.isRequired,
  onReblog: PropTypes.func.isRequired,
  onClose: PropTypes.func.isRequired,
  intl: PropTypes.object.isRequired
};

export default injectIntl(BoostModal);

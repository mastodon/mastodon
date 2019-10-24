import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import Button from 'flavours/glitch/components/button';
import StatusContent from 'flavours/glitch/components/status_content';
import Avatar from 'flavours/glitch/components/avatar';
import RelativeTimestamp from 'flavours/glitch/components/relative_timestamp';
import DisplayName from 'flavours/glitch/components/display_name';
import AttachmentList from 'flavours/glitch/components/attachment_list';
import Icon from 'flavours/glitch/components/icon';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  cancel_reblog: { id: 'status.cancel_reblog_private', defaultMessage: 'Unboost' },
  reblog: { id: 'status.reblog', defaultMessage: 'Boost' },
});

export default @injectIntl
class BoostModal extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    onReblog: PropTypes.func.isRequired,
    onClose: PropTypes.func.isRequired,
    missingMediaDescription: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount() {
    this.button.focus();
  }

  handleReblog = () => {
    this.props.onReblog(this.props.status);
    this.props.onClose();
  }

  handleAccountClick = (e) => {
    if (e.button === 0) {
      e.preventDefault();
      this.props.onClose();
      let state = {...this.context.router.history.location.state};
      state.mastodonBackSteps = (state.mastodonBackSteps || 0) + 1;
      this.context.router.history.push(`/accounts/${this.props.status.getIn(['account', 'id'])}`, state);
    }
  }

  setRef = (c) => {
    this.button = c;
  }

  render () {
    const { status, missingMediaDescription, intl } = this.props;
    const buttonText = status.get('reblogged') ? messages.cancel_reblog : messages.reblog;

    return (
      <div className='modal-root__modal boost-modal'>
        <div className='boost-modal__container'>
          <div className='status light'>
            <div className='boost-modal__status-header'>
              <div className='boost-modal__status-time'>
                <a href={status.get('url')} className='status__relative-time' target='_blank' rel='noopener noreferrer'><RelativeTimestamp timestamp={status.get('created_at')} /></a>
              </div>

              <a onClick={this.handleAccountClick} href={status.getIn(['account', 'url'])} className='status__display-name'>
                <div className='status__avatar'>
                  <Avatar account={status.get('account')} size={48} />
                </div>

                <DisplayName account={status.get('account')} />
              </a>
            </div>

            <StatusContent status={status} />

            {status.get('media_attachments').size > 0 && (
              <AttachmentList
                compact
                media={status.get('media_attachments')}
              />
            )}
          </div>
        </div>

        <div className='boost-modal__action-bar'>
          <div>
            { missingMediaDescription ?
                <FormattedMessage id='boost_modal.missing_description' defaultMessage='This toot contains some media without description' />
              :
                <FormattedMessage id='boost_modal.combo' defaultMessage='You can press {combo} to skip this next time' values={{ combo: <span>Shift + <Icon id='retweet' /></span> }} />
            }
          </div>
          <Button text={intl.formatMessage(buttonText)} onClick={this.handleReblog} ref={this.setRef} />
        </div>
      </div>
    );
  }

}

import PropTypes from 'prop-types';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import AttachmentList from 'flavours/glitch/components/attachment_list';
import { Avatar } from 'flavours/glitch/components/avatar';
import Button from 'flavours/glitch/components/button';
import { DisplayName } from 'flavours/glitch/components/display_name';
import { Icon } from 'flavours/glitch/components/icon';
import { RelativeTimestamp } from 'flavours/glitch/components/relative_timestamp';
import StatusContent from 'flavours/glitch/components/status_content';
import VisibilityIcon from 'flavours/glitch/components/status_visibility_icon';

const messages = defineMessages({
  favourite: { id: 'status.favourite', defaultMessage: 'Favourite' },
});

class FavouriteModal extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    onFavourite: PropTypes.func.isRequired,
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount() {
    this.button.focus();
  }

  handleFavourite = () => {
    this.props.onFavourite(this.props.status);
    this.props.onClose();
  };

  handleAccountClick = (e) => {
    if (e.button === 0) {
      e.preventDefault();
      this.props.onClose();
      this.context.router.history.push(`/@${this.props.status.getIn(['account', 'acct'])}`);
    }
  };

  setRef = (c) => {
    this.button = c;
  };

  render () {
    const { status, intl } = this.props;

    return (
      <div className='modal-root__modal boost-modal'>
        <div className='boost-modal__container'>
          <div className={classNames('status', `status-${status.get('visibility')}`, 'light')}>
            <div className='boost-modal__status-header'>
              <div className='boost-modal__status-time'>
                <a href={status.get('url')} className='status__relative-time' target='_blank' rel='noopener noreferrer'>
                  <VisibilityIcon visibility={status.get('visibility')} />
                  <RelativeTimestamp timestamp={status.get('created_at')} />
                </a>
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
          <div><FormattedMessage id='favourite_modal.combo' defaultMessage='You can press {combo} to skip this next time' values={{ combo: <span>Shift + <Icon id='star' /></span> }} /></div>
          <Button text={intl.formatMessage(messages.favourite)} onClick={this.handleFavourite} ref={this.setRef} />
        </div>
      </div>
    );
  }

}

export default injectIntl(FavouriteModal);

import PropTypes from 'prop-types';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { withRouter } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import StarIcon from '@/material-icons/400-24px/star-fill.svg?react';
import AttachmentList from 'flavours/glitch/components/attachment_list';
import { Avatar } from 'flavours/glitch/components/avatar';
import { Button } from 'flavours/glitch/components/button';
import { DisplayName } from 'flavours/glitch/components/display_name';
import { Icon } from 'flavours/glitch/components/icon';
import { RelativeTimestamp } from 'flavours/glitch/components/relative_timestamp';
import StatusContent from 'flavours/glitch/components/status_content';
import { VisibilityIcon } from 'flavours/glitch/components/visibility_icon';
import { WithRouterPropTypes } from 'flavours/glitch/utils/react_router';

const messages = defineMessages({
  favourite: { id: 'status.favourite', defaultMessage: 'Favorite' },
});

class FavouriteModal extends ImmutablePureComponent {

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    onFavourite: PropTypes.func.isRequired,
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    ...WithRouterPropTypes,
  };

  handleFavourite = () => {
    this.props.onFavourite(this.props.status);
    this.props.onClose();
  };

  handleAccountClick = (e) => {
    if (e.button === 0) {
      e.preventDefault();
      this.props.onClose();
      this.props.history.push(`/@${this.props.status.getIn(['account', 'acct'])}`);
    }
  };

  render () {
    const { status, intl } = this.props;

    return (
      <div className='modal-root__modal boost-modal'>
        <div className='boost-modal__container'>
          <div className={classNames('status', `status-${status.get('visibility')}`, 'light')}>
            <div className='status__info'>
              <a href={status.get('url')} className='status__relative-time' target='_blank' rel='noopener noreferrer'>
                <span className='status__visibility-icon'><VisibilityIcon visibility={status.get('visibility')} /></span>
                <RelativeTimestamp timestamp={status.get('created_at')} />
              </a>

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
          <div><FormattedMessage id='favourite_modal.combo' defaultMessage='You can press {combo} to skip this next time' values={{ combo: <span>Shift + <Icon id='star' icon={StarIcon} /></span> }} /></div>
          <Button text={intl.formatMessage(messages.favourite)} onClick={this.handleFavourite} autoFocus />
        </div>
      </div>
    );
  }

}

export default withRouter(injectIntl(FavouriteModal));

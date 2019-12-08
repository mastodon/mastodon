import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Video from 'flavours/glitch/features/video';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { FormattedMessage } from 'react-intl';
import classNames from 'classnames';
import Icon from 'flavours/glitch/components/icon';

export default class VideoModal extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    media: ImmutablePropTypes.map.isRequired,
    status: ImmutablePropTypes.map,
    time: PropTypes.number,
    onClose: PropTypes.func.isRequired,
  };

  handleStatusClick = e => {
    if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      this.context.router.history.push(`/statuses/${this.props.status.get('id')}`);
    }
  }

  render () {
    const { media, status, time, onClose } = this.props;

    return (
      <div className='modal-root__modal video-modal'>
        <div className='video-modal__container'>
          <Video
            preview={media.get('preview_url')}
            blurhash={media.get('blurhash')}
            src={media.get('url')}
            startTime={time}
            onCloseVideo={onClose}
            detailed
            alt={media.get('description')}
          />
        </div>

        {status && (
          <div className={classNames('media-modal__meta')}>
            <a href={status.get('url')} onClick={this.handleStatusClick}><Icon id='comments' /> <FormattedMessage id='lightbox.view_context' defaultMessage='View context' /></a>
          </div>
        )}
      </div>
    );
  }

}

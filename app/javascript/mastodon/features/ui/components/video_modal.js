import React from 'react';
import LoadingIndicator from '../../../components/loading_indicator';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import ExtendedVideoPlayer from '../../../components/extended_video_player';
import { defineMessages, injectIntl } from 'react-intl';
import IconButton from '../../../components/icon_button';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' }
});

class VideoModal extends ImmutablePureComponent {

  render () {
    const { media, intl, time, onClose } = this.props;

    const url = media.get('url');

    return (
      <div className='modal-root__modal media-modal'>
        <div>
          <div className='media-modal__close'><IconButton title={intl.formatMessage(messages.close)} icon='times' overlay onClick={onClose} /></div>
          <ExtendedVideoPlayer src={url} muted={false} controls={true} time={time} />
        </div>
      </div>
    );
  }

}

VideoModal.propTypes = {
  media: ImmutablePropTypes.map.isRequired,
  time: PropTypes.number,
  onClose: PropTypes.func.isRequired,
  intl: PropTypes.object.isRequired
};

export default injectIntl(VideoModal);

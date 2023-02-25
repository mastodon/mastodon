import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Video from 'mastodon/features/video';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Footer from 'mastodon/features/picture_in_picture/components/footer';
import { getAverageFromBlurhash } from 'mastodon/blurhash';

export default class VideoModal extends ImmutablePureComponent {

  static propTypes = {
    media: ImmutablePropTypes.map.isRequired,
    statusId: PropTypes.string,
    options: PropTypes.shape({
      startTime: PropTypes.number,
      autoPlay: PropTypes.bool,
      defaultVolume: PropTypes.number,
    }),
    onClose: PropTypes.func.isRequired,
    onChangeBackgroundColor: PropTypes.func.isRequired,
  };

  componentDidMount () {
    const { media, onChangeBackgroundColor } = this.props;

    const backgroundColor = getAverageFromBlurhash(media.get('blurhash'));

    if (backgroundColor) {
      onChangeBackgroundColor(backgroundColor);
    }
  }

  render () {
    const { media, statusId, onClose } = this.props;
    const options = this.props.options || {};

    return (
      <div className='modal-root__modal video-modal'>
        <div className='video-modal__container'>
          <Video
            preview={media.get('preview_url')}
            frameRate={media.getIn(['meta', 'original', 'frame_rate'])}
            blurhash={media.get('blurhash')}
            src={media.get('url')}
            currentTime={options.startTime}
            autoPlay={options.autoPlay}
            volume={options.defaultVolume}
            onCloseVideo={onClose}
            autoFocus
            detailed
            alt={media.get('description')}
          />
        </div>

        <div className='media-modal__overlay'>
          {statusId && <Footer statusId={statusId} withOpenButton onClose={onClose} />}
        </div>
      </div>
    );
  }

}

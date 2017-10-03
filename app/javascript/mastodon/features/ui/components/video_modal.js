import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Video from '../../video';
import ImmutablePureComponent from 'react-immutable-pure-component';

export default class VideoModal extends ImmutablePureComponent {

  static propTypes = {
    media: ImmutablePropTypes.map.isRequired,
    time: PropTypes.number,
    onClose: PropTypes.func.isRequired,
  };

  render () {
    const { media, time, onClose } = this.props;

    return (
      <div className='modal-root__modal media-modal'>
        <div>
          <Video
            preview={media.get('preview_url')}
            src={media.get('url')}
            startTime={time}
            onCloseVideo={onClose}
            description={media.get('description')}
          />
        </div>
      </div>
    );
  }

}

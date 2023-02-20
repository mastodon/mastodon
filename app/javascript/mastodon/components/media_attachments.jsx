import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { MediaGallery, Video, Audio } from 'mastodon/features/ui/util/async-components';
import Bundle from 'mastodon/features/ui/components/bundle';
import noop from 'lodash/noop';

export default class MediaAttachments extends ImmutablePureComponent {

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    height: PropTypes.number,
    width: PropTypes.number,
  };

  static defaultProps = {
    height: 110,
    width: 239,
  };

  updateOnProps = [
    'status',
  ];

  renderLoadingMediaGallery = () => {
    const { height, width } = this.props;

    return (
      <div className='media-gallery' style={{ height, width }} />
    );
  };

  renderLoadingVideoPlayer = () => {
    const { height, width } = this.props;

    return (
      <div className='video-player' style={{ height, width }} />
    );
  };

  renderLoadingAudioPlayer = () => {
    const { height, width } = this.props;

    return (
      <div className='audio-player' style={{ height, width }} />
    );
  };

  render () {
    const { status, width, height } = this.props;
    const mediaAttachments = status.get('media_attachments');

    if (mediaAttachments.size === 0) {
      return null;
    }

    if (mediaAttachments.getIn([0, 'type']) === 'audio') {
      const audio = mediaAttachments.get(0);

      return (
        <Bundle fetchComponent={Audio} loading={this.renderLoadingAudioPlayer} >
          {Component => (
            <Component
              src={audio.get('url')}
              alt={audio.get('description')}
              width={width}
              height={height}
              poster={audio.get('preview_url') || status.getIn(['account', 'avatar_static'])}
              backgroundColor={audio.getIn(['meta', 'colors', 'background'])}
              foregroundColor={audio.getIn(['meta', 'colors', 'foreground'])}
              accentColor={audio.getIn(['meta', 'colors', 'accent'])}
              duration={audio.getIn(['meta', 'original', 'duration'], 0)}
            />
          )}
        </Bundle>
      );
    } else if (mediaAttachments.getIn([0, 'type']) === 'video') {
      const video = mediaAttachments.get(0);

      return (
        <Bundle fetchComponent={Video} loading={this.renderLoadingVideoPlayer} >
          {Component => (
            <Component
              preview={video.get('preview_url')}
              frameRate={video.getIn(['meta', 'original', 'frame_rate'])}
              blurhash={video.get('blurhash')}
              src={video.get('url')}
              alt={video.get('description')}
              width={width}
              height={height}
              inline
              sensitive={status.get('sensitive')}
              onOpenVideo={noop}
            />
          )}
        </Bundle>
      );
    } else {
      return (
        <Bundle fetchComponent={MediaGallery} loading={this.renderLoadingMediaGallery} >
          {Component => (
            <Component
              media={mediaAttachments}
              sensitive={status.get('sensitive')}
              defaultWidth={width}
              height={height}
              onOpenMedia={noop}
            />
          )}
        </Bundle>
      );
    }
  }

}

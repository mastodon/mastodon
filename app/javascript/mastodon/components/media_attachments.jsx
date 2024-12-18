import PropTypes from 'prop-types';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import noop from 'lodash/noop';

import Bundle from 'mastodon/features/ui/components/bundle';
import { MediaGallery, Video, Audio } from 'mastodon/features/ui/util/async-components';

export default class MediaAttachments extends ImmutablePureComponent {

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    lang: PropTypes.string,
    height: PropTypes.number,
    width: PropTypes.number,
    visible: PropTypes.bool,
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
    const { status, width, height, visible } = this.props;
    const mediaAttachments = status.get('media_attachments');
    const language = status.getIn(['language', 'translation']) || status.get('language') || this.props.lang;

    if (mediaAttachments.size === 0) {
      return null;
    }

    if (mediaAttachments.getIn([0, 'type']) === 'audio') {
      const audio = mediaAttachments.get(0);
      const description = audio.getIn(['translation', 'description']) || audio.get('description');

      return (
        <Bundle fetchComponent={Audio} loading={this.renderLoadingAudioPlayer} >
          {Component => (
            <Component
              src={audio.get('url')}
              alt={description}
              lang={language}
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
      const description = video.getIn(['translation', 'description']) || video.get('description');

      return (
        <Bundle fetchComponent={Video} loading={this.renderLoadingVideoPlayer} >
          {Component => (
            <Component
              preview={video.get('preview_url')}
              frameRate={video.getIn(['meta', 'original', 'frame_rate'])}
              blurhash={video.get('blurhash')}
              src={video.get('url')}
              alt={description}
              lang={language}
              width={width}
              height={height}
              inline
              sensitive={status.get('sensitive')}
              visible={visible}
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
              lang={language}
              sensitive={status.get('sensitive')}
              defaultWidth={width}
              visible={visible}
              height={height}
              onOpenMedia={noop}
            />
          )}
        </Bundle>
      );
    }
  }

}

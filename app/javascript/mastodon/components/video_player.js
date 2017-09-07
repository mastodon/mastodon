import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import IconButton from './icon_button';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { isIOS } from '../is_mobile';

const messages = defineMessages({
  toggle_sound: { id: 'video_player.toggle_sound', defaultMessage: 'Toggle sound' },
  toggle_visible: { id: 'video_player.toggle_visible', defaultMessage: 'Toggle visibility' },
  expand_video: { id: 'video_player.expand', defaultMessage: 'Expand video' },
});

@injectIntl
export default class VideoPlayer extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    media: ImmutablePropTypes.map.isRequired,
    width: PropTypes.number,
    height: PropTypes.number,
    sensitive: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    autoplay: PropTypes.bool,
    onOpenVideo: PropTypes.func.isRequired,
  };

  static defaultProps = {
    width: 239,
    height: 110,
  };

  state = {
    visible: !this.props.sensitive,
    preview: true,
    muted: true,
    hasAudio: true,
    videoError: false,
  };

  handleClick = () => {
    this.setState({ muted: !this.state.muted });
  }

  handleVideoClick = (e) => {
    e.stopPropagation();

    const node = this.video;

    if (node.paused) {
      node.play();
    } else {
      node.pause();
    }
  }

  handleOpen = () => {
    this.setState({ preview: !this.state.preview });
  }

  handleVisibility = () => {
    this.setState({
      visible: !this.state.visible,
      preview: true,
    });
  }

  handleExpand = () => {
    this.video.pause();
    this.props.onOpenVideo(this.props.media, this.video.currentTime);
  }

  setRef = (c) => {
    this.video = c;
  }

  handleLoadedData = () => {
    if (('WebkitAppearance' in document.documentElement.style && this.video.audioTracks.length === 0) || this.video.mozHasAudio === false) {
      this.setState({ hasAudio: false });
    }
  }

  handleVideoError = () => {
    this.setState({ videoError: true });
  }

  componentDidMount () {
    if (!this.video) {
      return;
    }

    this.video.addEventListener('loadeddata', this.handleLoadedData);
    this.video.addEventListener('error', this.handleVideoError);
  }

  componentDidUpdate () {
    if (!this.video) {
      return;
    }

    this.video.addEventListener('loadeddata', this.handleLoadedData);
    this.video.addEventListener('error', this.handleVideoError);
  }

  componentWillUnmount () {
    if (!this.video) {
      return;
    }

    this.video.removeEventListener('loadeddata', this.handleLoadedData);
    this.video.removeEventListener('error', this.handleVideoError);
  }

  render () {
    const { media, intl, width, height, sensitive, autoplay } = this.props;

    let spoilerButton = (
      <div className={`status__video-player-spoiler ${this.state.visible ? 'status__video-player-spoiler--visible' : ''}`}>
        <IconButton overlay title={intl.formatMessage(messages.toggle_visible)} icon={this.state.visible ? 'eye' : 'eye-slash'} onClick={this.handleVisibility} />
      </div>
    );

    let expandButton = '';

    if (this.context.router) {
      expandButton = (
        <div className='status__video-player-expand'>
          <IconButton overlay title={intl.formatMessage(messages.expand_video)} icon='expand' onClick={this.handleExpand} />
        </div>
      );
    }

    let muteButton = '';

    if (this.state.hasAudio) {
      muteButton = (
        <div className='status__video-player-mute'>
          <IconButton overlay title={intl.formatMessage(messages.toggle_sound)} icon={this.state.muted ? 'volume-off' : 'volume-up'} onClick={this.handleClick} />
        </div>
      );
    }

    if (!this.state.visible) {
      if (sensitive) {
        return (
          <button style={{ width: `${width}px`, height: `${height}px`, marginTop: '8px' }} className='media-spoiler' onClick={this.handleVisibility}>
            {spoilerButton}
            <span className='media-spoiler__warning'><FormattedMessage id='status.sensitive_warning' defaultMessage='Sensitive content' /></span>
            <span className='media-spoiler__trigger'><FormattedMessage id='status.sensitive_toggle' defaultMessage='Click to view' /></span>
          </button>
        );
      } else {
        return (
          <button style={{ width: `${width}px`, height: `${height}px`, marginTop: '8px' }} className='media-spoiler' onClick={this.handleVisibility}>
            {spoilerButton}
            <span className='media-spoiler__warning'><FormattedMessage id='status.media_hidden' defaultMessage='Media hidden' /></span>
            <span className='media-spoiler__trigger'><FormattedMessage id='status.sensitive_toggle' defaultMessage='Click to view' /></span>
          </button>
        );
      }
    }

    if (this.state.preview && !autoplay) {
      return (
        <button className='media-spoiler-video' style={{ width: `${width}px`, height: `${height}px`, backgroundImage: `url(${media.get('preview_url')})` }} onClick={this.handleOpen}>
          {spoilerButton}
          <div className='media-spoiler-video-play-icon'><i className='fa fa-play' /></div>
        </button>
      );
    }

    if (this.state.videoError) {
      return (
        <div style={{ width: `${width}px`, height: `${height}px` }} className='video-error-cover' >
          <span className='media-spoiler__warning'><FormattedMessage id='video_player.video_error' defaultMessage='Video could not be played' /></span>
        </div>
      );
    }

    return (
      <div className='status__video-player' style={{ width: `${width}px`, height: `${height}px` }}>
        {spoilerButton}
        {muteButton}
        {expandButton}

        <video
          className='status__video-player-video'
          role='button'
          tabIndex='0'
          ref={this.setRef}
          src={media.get('url')}
          autoPlay={!isIOS()}
          loop
          muted={this.state.muted}
          onClick={this.handleVideoClick}
        />
      </div>
    );
  }

}

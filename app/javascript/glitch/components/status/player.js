//  Package imports  //
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

//  Mastodon imports  //
import IconButton from '../../../mastodon/components/icon_button';
import { isIOS } from '../../../mastodon/is_mobile';

const messages = defineMessages({
  toggle_sound: { id: 'video_player.toggle_sound', defaultMessage: 'Toggle sound' },
  toggle_visible: { id: 'video_player.toggle_visible', defaultMessage: 'Toggle visibility' },
  expand_video: { id: 'video_player.expand', defaultMessage: 'Expand video' },
});

@injectIntl
export default class StatusPlayer extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    media: ImmutablePropTypes.map.isRequired,
    letterbox: PropTypes.bool,
    fullwidth: PropTypes.bool,
    height: PropTypes.number,
    sensitive: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    autoplay: PropTypes.bool,
    onOpenVideo: PropTypes.func.isRequired,
  };

  static defaultProps = {
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
    const { media, intl, letterbox, fullwidth, height, sensitive, autoplay } = this.props;

    let spoilerButton = (
      <div className={`status__video-player-spoiler ${this.state.visible ? 'status__video-player-spoiler--visible' : ''}`}>
        <IconButton overlay title={intl.formatMessage(messages.toggle_visible)} icon={this.state.visible ? 'eye' : 'eye-slash'} onClick={this.handleVisibility} />
      </div>
    );

    let expandButton = !this.context.router ? '' : (
      <div className='status__video-player-expand'>
        <IconButton overlay title={intl.formatMessage(messages.expand_video)} icon='expand' onClick={this.handleExpand} />
      </div>
    );

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
          <div role='button' tabIndex='0' style={{ height: `${height}px` }} className={`media-spoiler ${fullwidth ? 'full-width' : ''}`} onClick={this.handleVisibility}>
            {spoilerButton}
            <span className='media-spoiler__warning'><FormattedMessage id='status.sensitive_warning' defaultMessage='Sensitive content' /></span>
            <span className='media-spoiler__trigger'><FormattedMessage id='status.sensitive_toggle' defaultMessage='Click to view' /></span>
          </div>
        );
      } else {
        return (
          <div role='button' tabIndex='0' style={{ height: `${height}px` }} className={`media-spoiler ${fullwidth ? 'full-width' : ''}`} onClick={this.handleVisibility}>
            {spoilerButton}
            <span className='media-spoiler__warning'><FormattedMessage id='status.media_hidden' defaultMessage='Media hidden' /></span>
            <span className='media-spoiler__trigger'><FormattedMessage id='status.sensitive_toggle' defaultMessage='Click to view' /></span>
          </div>
        );
      }
    }

    if (this.state.preview && !autoplay) {
      return (
        <div role='button' tabIndex='0' className={`media-spoiler-video ${fullwidth ? 'full-width' : ''}`} style={{ height: `${height}px`, backgroundImage: `url(${media.get('preview_url')})` }} onClick={this.handleOpen}>
          {spoilerButton}
          <div className='media-spoiler-video-play-icon'><i className='fa fa-play' /></div>
        </div>
      );
    }

    if (this.state.videoError) {
      return (
        <div style={{ height: `${height}px` }} className='video-error-cover' >
          <span className='media-spoiler__warning'><FormattedMessage id='video_player.video_error' defaultMessage='Video could not be played' /></span>
        </div>
      );
    }

    return (
      <div className={`status__video-player ${fullwidth ? 'full-width' : ''}`} style={{ height: `${height}px` }}>
        {spoilerButton}
        {muteButton}
        {expandButton}

        <video
          className={`status__video-player-video${letterbox ? ' letterbox' : ''}`}
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

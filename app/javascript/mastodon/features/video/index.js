import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { fromJS } from 'immutable';
import { throttle } from 'lodash';
import classNames from 'classnames';
import { isFullscreen, requestFullscreen, exitFullscreen } from '../ui/util/fullscreen';
import { displaySensitiveMedia } from '../../initial_state';

const messages = defineMessages({
  play: { id: 'video.play', defaultMessage: 'Play' },
  pause: { id: 'video.pause', defaultMessage: 'Pause' },
  mute: { id: 'video.mute', defaultMessage: 'Mute sound' },
  unmute: { id: 'video.unmute', defaultMessage: 'Unmute sound' },
  hide: { id: 'video.hide', defaultMessage: 'Hide video' },
  expand: { id: 'video.expand', defaultMessage: 'Expand video' },
  close: { id: 'video.close', defaultMessage: 'Close video' },
  fullscreen: { id: 'video.fullscreen', defaultMessage: 'Full screen' },
  exit_fullscreen: { id: 'video.exit_fullscreen', defaultMessage: 'Exit full screen' },
});

const formatTime = secondsNum => {
  let hours   = Math.floor(secondsNum / 3600);
  let minutes = Math.floor((secondsNum - (hours * 3600)) / 60);
  let seconds = secondsNum - (hours * 3600) - (minutes * 60);

  if (hours   < 10) hours   = '0' + hours;
  if (minutes < 10) minutes = '0' + minutes;
  if (seconds < 10) seconds = '0' + seconds;

  return (hours === '00' ? '' : `${hours}:`) + `${minutes}:${seconds}`;
};

export const findElementPosition = el => {
  let box;

  if (el.getBoundingClientRect && el.parentNode) {
    box = el.getBoundingClientRect();
  }

  if (!box) {
    return {
      left: 0,
      top: 0,
    };
  }

  const docEl = document.documentElement;
  const body  = document.body;

  const clientLeft = docEl.clientLeft || body.clientLeft || 0;
  const scrollLeft = window.pageXOffset || body.scrollLeft;
  const left       = (box.left + scrollLeft) - clientLeft;

  const clientTop = docEl.clientTop || body.clientTop || 0;
  const scrollTop = window.pageYOffset || body.scrollTop;
  const top       = (box.top + scrollTop) - clientTop;

  return {
    left: Math.round(left),
    top: Math.round(top),
  };
};

export const getPointerPosition = (el, event) => {
  const position = {};
  const box = findElementPosition(el);
  const boxW = el.offsetWidth;
  const boxH = el.offsetHeight;
  const boxY = box.top;
  const boxX = box.left;

  let pageY = event.pageY;
  let pageX = event.pageX;

  if (event.changedTouches) {
    pageX = event.changedTouches[0].pageX;
    pageY = event.changedTouches[0].pageY;
  }

  position.y = Math.max(0, Math.min(1, (pageY - boxY) / boxH));
  position.x = Math.max(0, Math.min(1, (pageX - boxX) / boxW));

  return position;
};

@injectIntl
export default class Video extends React.PureComponent {

  static propTypes = {
    preview: PropTypes.string,
    src: PropTypes.string.isRequired,
    alt: PropTypes.string,
    width: PropTypes.number,
    height: PropTypes.number,
    sensitive: PropTypes.bool,
    startTime: PropTypes.number,
    onOpenVideo: PropTypes.func,
    onCloseVideo: PropTypes.func,
    detailed: PropTypes.bool,
    inline: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  state = {
    currentTime: 0,
    duration: 0,
    paused: true,
    dragging: false,
    containerWidth: false,
    fullscreen: false,
    hovered: false,
    muted: false,
    revealed: !this.props.sensitive || displaySensitiveMedia,
  };

  setPlayerRef = c => {
    this.player = c;

    if (c) {
      this.setState({
        containerWidth: c.offsetWidth,
      });
    }
  }

  setVideoRef = c => {
    this.video = c;
  }

  setSeekRef = c => {
    this.seek = c;
  }

  handleClickRoot = e => e.stopPropagation();

  handlePlay = () => {
    this.setState({ paused: false });
  }

  handlePause = () => {
    this.setState({ paused: true });
  }

  handleTimeUpdate = () => {
    this.setState({
      currentTime: Math.floor(this.video.currentTime),
      duration: Math.floor(this.video.duration),
    });
  }

  handleMouseDown = e => {
    document.addEventListener('mousemove', this.handleMouseMove, true);
    document.addEventListener('mouseup', this.handleMouseUp, true);
    document.addEventListener('touchmove', this.handleMouseMove, true);
    document.addEventListener('touchend', this.handleMouseUp, true);

    this.setState({ dragging: true });
    this.video.pause();
    this.handleMouseMove(e);
  }

  handleMouseUp = () => {
    document.removeEventListener('mousemove', this.handleMouseMove, true);
    document.removeEventListener('mouseup', this.handleMouseUp, true);
    document.removeEventListener('touchmove', this.handleMouseMove, true);
    document.removeEventListener('touchend', this.handleMouseUp, true);

    this.setState({ dragging: false });
    this.video.play();
  }

  handleMouseMove = throttle(e => {
    const { x } = getPointerPosition(this.seek, e);
    const currentTime = Math.floor(this.video.duration * x);

    this.video.currentTime = currentTime;
    this.setState({ currentTime });
  }, 60);

  togglePlay = () => {
    if (this.state.paused) {
      this.video.play();
    } else {
      this.video.pause();
    }
  }

  toggleFullscreen = () => {
    if (isFullscreen()) {
      exitFullscreen();
    } else {
      requestFullscreen(this.player);
    }
  }

  componentDidMount () {
    document.addEventListener('fullscreenchange', this.handleFullscreenChange, true);
    document.addEventListener('webkitfullscreenchange', this.handleFullscreenChange, true);
    document.addEventListener('mozfullscreenchange', this.handleFullscreenChange, true);
    document.addEventListener('MSFullscreenChange', this.handleFullscreenChange, true);
  }

  componentWillUnmount () {
    document.removeEventListener('fullscreenchange', this.handleFullscreenChange, true);
    document.removeEventListener('webkitfullscreenchange', this.handleFullscreenChange, true);
    document.removeEventListener('mozfullscreenchange', this.handleFullscreenChange, true);
    document.removeEventListener('MSFullscreenChange', this.handleFullscreenChange, true);
  }

  handleFullscreenChange = () => {
    this.setState({ fullscreen: isFullscreen() });
  }

  handleMouseEnter = () => {
    this.setState({ hovered: true });
  }

  handleMouseLeave = () => {
    this.setState({ hovered: false });
  }

  toggleMute = () => {
    this.video.muted = !this.video.muted;
    this.setState({ muted: this.video.muted });
  }

  toggleReveal = () => {
    if (this.state.revealed) {
      this.video.pause();
    }

    this.setState({ revealed: !this.state.revealed });
  }

  handleLoadedData = () => {
    if (this.props.startTime) {
      this.video.currentTime = this.props.startTime;
      this.video.play();
    }
  }

  handleProgress = () => {
    if (this.video.buffered.length > 0) {
      this.setState({ buffer: this.video.buffered.end(0) / this.video.duration * 100 });
    }
  }

  handleOpenVideo = () => {
    const { src, preview, width, height } = this.props;
    const media = fromJS({
      type: 'video',
      url: src,
      preview_url: preview,
      width,
      height,
    });

    this.video.pause();
    this.props.onOpenVideo(media, this.video.currentTime);
  }

  handleCloseVideo = () => {
    this.video.pause();
    this.props.onCloseVideo();
  }

  render () {
    const { preview, src, inline, startTime, onOpenVideo, onCloseVideo, intl, alt, detailed } = this.props;
    const { containerWidth, currentTime, duration, buffer, dragging, paused, fullscreen, hovered, muted, revealed } = this.state;
    const progress = (currentTime / duration) * 100;
    const playerStyle = {};

    let { width, height } = this.props;

    if (inline && containerWidth) {
      width  = containerWidth;
      height = containerWidth / (16/9);

      playerStyle.width  = width;
      playerStyle.height = height;
    }

    return (
      <div
        role='menuitem'
        className={classNames('video-player', { inactive: !revealed, detailed, inline: inline && !fullscreen, fullscreen })}
        style={playerStyle}
        ref={this.setPlayerRef}
        onMouseEnter={this.handleMouseEnter}
        onMouseLeave={this.handleMouseLeave}
        onClick={this.handleClickRoot}
        tabIndex={0}
      >
        <video
          ref={this.setVideoRef}
          src={src}
          poster={preview}
          preload={startTime ? 'auto' : 'none'}
          loop
          role='button'
          tabIndex='0'
          aria-label={alt}
          width={width}
          height={height}
          onClick={this.togglePlay}
          onPlay={this.handlePlay}
          onPause={this.handlePause}
          onTimeUpdate={this.handleTimeUpdate}
          onLoadedData={this.handleLoadedData}
          onProgress={this.handleProgress}
        />

        <button type='button' className={classNames('video-player__spoiler', { active: !revealed })} onClick={this.toggleReveal}>
          <span className='video-player__spoiler__title'><FormattedMessage id='status.sensitive_warning' defaultMessage='Sensitive content' /></span>
          <span className='video-player__spoiler__subtitle'><FormattedMessage id='status.sensitive_toggle' defaultMessage='Click to view' /></span>
        </button>

        <div className={classNames('video-player__controls', { active: paused || hovered })}>
          <div className='video-player__seek' onMouseDown={this.handleMouseDown} ref={this.setSeekRef}>
            <div className='video-player__seek__buffer' style={{ width: `${buffer}%` }} />
            <div className='video-player__seek__progress' style={{ width: `${progress}%` }} />

            <span
              className={classNames('video-player__seek__handle', { active: dragging })}
              tabIndex='0'
              style={{ left: `${progress}%` }}
            />
          </div>

          <div className='video-player__buttons-bar'>
            <div className='video-player__buttons left'>
              <button type='button' aria-label={intl.formatMessage(paused ? messages.play : messages.pause)} onClick={this.togglePlay}><i className={classNames('fa fa-fw', { 'fa-play': paused, 'fa-pause': !paused })} /></button>
              <button type='button' aria-label={intl.formatMessage(muted ? messages.unmute : messages.mute)} onClick={this.toggleMute}><i className={classNames('fa fa-fw', { 'fa-volume-off': muted, 'fa-volume-up': !muted })} /></button>

              {!onCloseVideo && <button type='button' aria-label={intl.formatMessage(messages.hide)} onClick={this.toggleReveal}><i className='fa fa-fw fa-eye' /></button>}

              {(detailed || fullscreen) &&
                <span>
                  <span className='video-player__time-current'>{formatTime(currentTime)}</span>
                  <span className='video-player__time-sep'>/</span>
                  <span className='video-player__time-total'>{formatTime(duration)}</span>
                </span>
              }
            </div>

            <div className='video-player__buttons right'>
              {(!fullscreen && onOpenVideo) && <button type='button' aria-label={intl.formatMessage(messages.expand)} onClick={this.handleOpenVideo}><i className='fa fa-fw fa-expand' /></button>}
              {onCloseVideo && <button type='button' aria-label={intl.formatMessage(messages.close)} onClick={this.handleCloseVideo}><i className='fa fa-fw fa-compress' /></button>}
              <button type='button' aria-label={intl.formatMessage(fullscreen ? messages.exit_fullscreen : messages.fullscreen)} onClick={this.toggleFullscreen}><i className={classNames('fa fa-fw', { 'fa-arrows-alt': !fullscreen, 'fa-compress': fullscreen })} /></button>
            </div>
          </div>
        </div>
      </div>
    );
  }

}

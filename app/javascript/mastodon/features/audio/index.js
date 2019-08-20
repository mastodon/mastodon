import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { fromJS, is } from 'immutable';
import { throttle } from 'lodash';
import classNames from 'classnames';
import { displayMedia, useBlurhash } from '../../initial_state';
import Icon from 'mastodon/components/icon';
import { decode } from 'blurhash';
import { getPointerPosition } from 'mastodon/features/video';   

const messages = defineMessages({
  play: { id: 'video.play', defaultMessage: 'Play' },
  pause: { id: 'video.pause', defaultMessage: 'Pause' },
  mute: { id: 'video.mute', defaultMessage: 'Mute sound' },
  unmute: { id: 'video.unmute', defaultMessage: 'Unmute sound' },
  hide: { id: 'video.hide', defaultMessage: 'Hide video' },
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

export default @injectIntl
class Audio extends React.PureComponent {

  static propTypes = {
    preview: PropTypes.string,
    src: PropTypes.string.isRequired,
    alt: PropTypes.string,
    sensitive: PropTypes.bool,
    startTime: PropTypes.number,
    onOpenVideo: PropTypes.func,
    onCloseVideo: PropTypes.func,
    detailed: PropTypes.bool,
    inline: PropTypes.bool,
    editable: PropTypes.bool,
    visible: PropTypes.bool,
    onToggleVisibility: PropTypes.func,
    intl: PropTypes.object.isRequired,
    blurhash: PropTypes.string,
    link: PropTypes.node,
  };

  state = {
    currentTime: 0,
    duration: 0,
    volume: 0.5,
    paused: true,
    dragging: false,
    muted: false,
    revealed: this.props.visible !== undefined ? this.props.visible : (displayMedia !== 'hide_all' && !this.props.sensitive || displayMedia === 'show_all'),
  };

  // hard coded in components.scss
  // any way to get ::before values programatically?
  volWidth = 50;
  volOffset = 70;
  volHandleOffset = v => {
    const offset = v * this.volWidth + this.volOffset;
    return (offset > 110) ? 110 : offset;
  }

  setPlayerRef = c => {
    this.player = c;
  }

  setVideoRef = c => {
    this.video = c;

    if (this.video) {
      this.setState({ volume: this.video.volume, muted: this.video.muted });
    }
  }

  setSeekRef = c => {
    this.seek = c;
  }

  setVolumeRef = c => {
    this.volume = c;
  }

  setCanvasRef = c => {
    this.canvas = c;
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

  handleVolumeMouseDown = e => {
    document.addEventListener('mousemove', this.handleMouseVolSlide, true);
    document.addEventListener('mouseup', this.handleVolumeMouseUp, true);
    document.addEventListener('touchmove', this.handleMouseVolSlide, true);
    document.addEventListener('touchend', this.handleVolumeMouseUp, true);

    this.handleMouseVolSlide(e);

    e.preventDefault();
    e.stopPropagation();
  }

  handleVolumeMouseUp = () => {
    document.removeEventListener('mousemove', this.handleMouseVolSlide, true);
    document.removeEventListener('mouseup', this.handleVolumeMouseUp, true);
    document.removeEventListener('touchmove', this.handleMouseVolSlide, true);
    document.removeEventListener('touchend', this.handleVolumeMouseUp, true);
  }

  handleMouseVolSlide = throttle(e => {
    const rect = this.volume.getBoundingClientRect();
    const x = (e.clientX - rect.left) / this.volWidth; //x position within the element.

    if(!isNaN(x)) {
      var slideamt = x;
      if(x > 1) {
        slideamt = 1;
      } else if(x < 0) {
        slideamt = 0;
      }
      this.video.volume = slideamt;
      this.setState({ volume: slideamt });
    }
  }, 60);

  handleMouseDown = e => {
    document.addEventListener('mousemove', this.handleMouseMove, true);
    document.addEventListener('mouseup', this.handleMouseUp, true);
    document.addEventListener('touchmove', this.handleMouseMove, true);
    document.addEventListener('touchend', this.handleMouseUp, true);

    this.setState({ dragging: true });
    this.video.pause();
    this.handleMouseMove(e);

    e.preventDefault();
    e.stopPropagation();
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

    if (!isNaN(currentTime)) {
      this.video.currentTime = currentTime;
      this.setState({ currentTime });
    }
  }, 60);

  togglePlay = () => {
    if (this.state.paused) {
      this.video.play();
    } else {
      this.video.pause();
    }
  }

  componentDidMount () {
    if (this.props.blurhash) {
      this._decode();
    }
  }

  componentWillReceiveProps (nextProps) {
    if (!is(nextProps.visible, this.props.visible) && nextProps.visible !== undefined) {
      this.setState({ revealed: nextProps.visible });
    }
  }

  componentDidUpdate (prevProps, prevState) {
    if (prevState.revealed && !this.state.revealed && this.video) {
      this.video.pause();
    }
    if (prevProps.blurhash !== this.props.blurhash && this.props.blurhash) {
      this._decode();
    }
  }

  _decode () {
    if (!useBlurhash) return;

    const hash   = this.props.blurhash;
    const pixels = decode(hash, 32, 32);

    if (pixels) {
      const ctx       = this.canvas.getContext('2d');
      const imageData = new ImageData(pixels, 32, 32);

      ctx.putImageData(imageData, 0, 0);
    }
  }

  toggleMute = () => {
    this.video.muted = !this.video.muted;
    this.setState({ muted: this.video.muted });
  }

  toggleReveal = () => {
    if (this.props.onToggleVisibility) {
      this.props.onToggleVisibility();
    } else {
      this.setState({ revealed: !this.state.revealed });
    }
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

  handleVolumeChange = () => {
    this.setState({ volume: this.video.volume, muted: this.video.muted });
  }

  render () {
    const { preview, src, inline, startTime, onOpenVideo, onCloseVideo, intl, alt, detailed, sensitive, link, editable } = this.props;
    const { currentTime, duration, volume, buffer, dragging, paused, muted, revealed } = this.state;
    const progress = (currentTime / duration) * 100;

    const volumeWidth = (muted) ? 0 : volume * this.volWidth;
    const volumeHandleLoc = (muted) ? this.volHandleOffset(0) : this.volHandleOffset(volume);

    let preload;

    if (startTime || dragging) {
      preload = 'auto';
    } else if (detailed) {
      preload = 'metadata';
    } else {
      preload = 'none';
    }

    let warning;

    if (sensitive) {
      warning = <FormattedMessage id='status.sensitive_warning' defaultMessage='Sensitive content' />;
    } else {
      warning = <FormattedMessage id='status.media_hidden' defaultMessage='Media hidden' />;
    }

    return (
      <div
        role='menuitem'
        className={classNames('video-player', { inactive: !revealed, detailed, inline, editable })}
        style={{ height: '70px' }}
        ref={this.setPlayerRef}
        onClick={this.handleClickRoot}
        tabIndex={0}
        title={alt}
      >
        {(revealed || editable) && <audio
          ref={this.setVideoRef}
          src={src}
          preload={preload}
          tabIndex='0'
          aria-label={alt}
          volume={volume}
          onClick={this.togglePlay}
          onPlay={this.handlePlay}
          onPause={this.handlePause}
          onTimeUpdate={this.handleTimeUpdate}
          onLoadedData={this.handleLoadedData}
          onProgress={this.handleProgress}
          onVolumeChange={this.handleVolumeChange}
        />}

        <div className={classNames('spoiler-button', { 'spoiler-button--hidden': revealed || editable })}>
          <button type='button' className='spoiler-button__overlay' onClick={this.toggleReveal}>
            <span className='spoiler-button__overlay__label'>{warning}</span>
          </button>
        </div>

        <div className={classNames('video-player__controls', { active: true })}>
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
              <button type='button' aria-label={intl.formatMessage(paused ? messages.play : messages.pause)} onClick={this.togglePlay}><Icon id={paused ? 'play' : 'pause'} fixedWidth /></button>
              <button type='button' aria-label={intl.formatMessage(muted ? messages.unmute : messages.mute)} onClick={this.toggleMute}><Icon id={muted ? 'volume-off' : 'volume-up'} fixedWidth /></button>

              <div className='video-player__volume' onMouseDown={this.handleVolumeMouseDown} ref={this.setVolumeRef}>
                <div className='video-player__volume__current' style={{ width: `${volumeWidth}px` }} />
                <span
                  className={classNames('video-player__volume__handle')}
                  tabIndex='0'
                  style={{ left: `${volumeHandleLoc}px` }}
                />
              </div>

              {detailed && (
                <span>
                  <span className='video-player__time-current'>{formatTime(currentTime)}</span>
                  <span className='video-player__time-sep'>/</span>
                  <span className='video-player__time-total'>{formatTime(duration)}</span>
                </span>
              )}

              {link && <span className='video-player__link'>{link}</span>}
            </div>

            <div className='video-player__buttons right'>
              {(!onCloseVideo && !editable) && <button type='button' aria-label={intl.formatMessage(messages.hide)} onClick={this.toggleReveal}><Icon id='eye-slash' fixedWidth /></button>}
            </div>
          </div>
        </div>
      </div>
    );
  }

}

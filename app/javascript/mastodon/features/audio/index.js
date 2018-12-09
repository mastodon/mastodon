import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import { throttle } from 'lodash';
import classNames from 'classnames';

const messages = defineMessages({
  play: { id: 'video.play', defaultMessage: 'Play' },
  pause: { id: 'video.pause', defaultMessage: 'Pause' },
  mute: { id: 'video.mute', defaultMessage: 'Mute sound' },
  unmute: { id: 'video.unmute', defaultMessage: 'Unmute sound' },
});

const formatTime = secondsNum => {
  let hours   = Math.floor(secondsNum / 3600);
  let minutes = Math.floor((secondsNum - (hours * 3600)) / 60);
  let seconds = Math.floor(secondsNum - (hours * 3600) - (minutes * 60));

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

// hard coded in components.scss
// any way to get ::before values programatically?
const VOL_WIDTH  = 50;
const VOL_OFFSET = 70;

export default @injectIntl
class Audio extends React.PureComponent {

  static propTypes = {
    src: PropTypes.string.isRequired,
    duration: PropTypes.number,
    intl: PropTypes.object.isRequired,
  };

  state = {
    currentTime: 0,
    duration: 0,
    volume: 0.5,
    paused: true,
    dragging: false,
    fullscreen: false,
    muted: false,
  };

  volHandleOffset = v => {
    const offset = v * VOL_WIDTH + VOL_OFFSET;
    return (offset > 110) ? 110 : offset;
  }

  componentDidMount () {
    this.setState({ duration: this.props.duration });
  }

  componentWillReceiveProps (nextProps) {
    this.setState({ duration: nextProps.duration });
  }

  setAudioRef = c => {
    this.audio = c;
  }

  setSeekRef = c => {
    this.seek = c;
  }

  setVolumeRef = c => {
    this.volume = c;
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
      currentTime: Math.floor(this.audio.currentTime),
      duration: Math.floor(this.audio.duration),
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
    const x = (e.clientX - rect.left) / VOL_WIDTH; //x position within the element.

    if(!isNaN(x)) {
      var slideamt = x;

      if(x > 1) {
        slideamt = 1;
      } else if(x < 0) {
        slideamt = 0;
      }

      this.audio.volume = slideamt;
      this.setState({ volume: slideamt });
    }
  }, 60);

  handleMouseDown = e => {
    document.addEventListener('mousemove', this.handleMouseMove, true);
    document.addEventListener('mouseup', this.handleMouseUp, true);
    document.addEventListener('touchmove', this.handleMouseMove, true);
    document.addEventListener('touchend', this.handleMouseUp, true);

    this.setState({ dragging: true });
    this.audio.pause();
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
    this.audio.play();
  }

  handleMouseMove = throttle(e => {
    const { x } = getPointerPosition(this.seek, e);
    const currentTime = Math.floor(this.audio.duration * x);

    if (!isNaN(currentTime)) {
      this.audio.currentTime = currentTime;
      this.setState({ currentTime });
    }
  }, 60);

  togglePlay = () => {
    if (this.state.paused) {
      this.audio.play();
    } else {
      this.audio.pause();
    }
  }

  toggleMute = () => {
    this.audio.muted = !this.audio.muted;
    this.setState({ muted: this.audio.muted });
  }

  handleProgress = () => {
    if (this.audio.buffered.length > 0) {
      this.setState({ buffer: this.audio.buffered.end(0) / this.audio.duration * 100 });
    }
  }

  render () {
    const { src, intl } = this.props;
    const { currentTime, duration, volume, buffer, dragging, paused, muted } = this.state;
    const progress = (currentTime / duration) * 100;
    const volumeWidth = (muted) ? 0 : volume * VOL_WIDTH;
    const volumeHandleLoc = (muted) ? this.volHandleOffset(0) : this.volHandleOffset(volume);

    return (
      <div
        role='menuitem'
        className='video-player inline audio-player'
        onClick={this.handleClickRoot}
        tabIndex={0}
      >
        <audio
          ref={this.setAudioRef}
          src={src}
          preload='none'
          loop
          role='button'
          tabIndex='0'
          volume={volume}
          onClick={this.togglePlay}
          onPlay={this.handlePlay}
          onPause={this.handlePause}
          onTimeUpdate={this.handleTimeUpdate}
          onProgress={this.handleProgress}
        />

        <div className='video-player__controls active'>
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
              <button type='button' aria-label={intl.formatMessage(muted ? messages.unmute : messages.mute)} onMouseEnter={this.volumeSlider} onMouseLeave={this.volumeSlider} onClick={this.toggleMute}><i className={classNames('fa fa-fw', { 'fa-volume-off': muted, 'fa-volume-up': !muted })} /></button>

              <div className='video-player__volume' onMouseDown={this.handleVolumeMouseDown} ref={this.setVolumeRef}>
                <div className='video-player__volume__current' style={{ width: `${volumeWidth}px` }} />

                <span
                  className={classNames('video-player__volume__handle')}
                  tabIndex='0'
                  style={{ left: `${volumeHandleLoc}px` }}
                />
              </div>
            </div>

            <div className='video-player__buttons right'>
              <span>
                <span className='video-player__time-current'>{formatTime(currentTime)}</span>
                <span className='video-player__time-sep'>/</span>
                <span className='video-player__time-total'>{formatTime(duration)}</span>
              </span>
            </div>
          </div>
        </div>
      </div>
    );
  }

}

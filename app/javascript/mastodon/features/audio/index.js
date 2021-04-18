import React from 'react';
import PropTypes from 'prop-types';
import WaveSurfer from 'wavesurfer.js';
import { defineMessages, injectIntl } from 'react-intl';
import { formatTime } from 'mastodon/features/video';
import Icon from 'mastodon/components/icon';
import classNames from 'classnames';
import { throttle } from 'lodash';

const messages = defineMessages({
  play: { id: 'video.play', defaultMessage: 'Play' },
  pause: { id: 'video.pause', defaultMessage: 'Pause' },
  mute: { id: 'video.mute', defaultMessage: 'Mute sound' },
  unmute: { id: 'video.unmute', defaultMessage: 'Unmute sound' },
  download: { id: 'video.download', defaultMessage: 'Download file' },
});

export default @injectIntl
class Audio extends React.PureComponent {

  static propTypes = {
    src: PropTypes.string.isRequired,
    alt: PropTypes.string,
    duration: PropTypes.number,
    peaks: PropTypes.arrayOf(PropTypes.number),
    height: PropTypes.number,
    preload: PropTypes.bool,
    editable: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  state = {
    currentTime: 0,
    duration: null,
    paused: true,
    muted: false,
    volume: 0.5,
  };

  // Hard coded in components.scss
  // Any way to get ::before values programatically?
  volWidth  = 50;
  volOffset = 70;

  volHandleOffset = v => {
    const offset = v * this.volWidth + this.volOffset;

    return (offset > 110) ? 110 : offset;
  }

  setVolumeRef = c => {
    this.volume = c;
  }

  setWaveformRef = c => {
    this.waveform = c;
  }

  componentDidMount () {
    if (this.waveform) {
      this._updateWaveform();
    }

    window.addEventListener('scroll', this.handleScroll);
  }

  componentDidUpdate (prevProps) {
    if (this.waveform && prevProps.src !== this.props.src) {
      this._updateWaveform();
    }
  }

  componentWillUnmount () {
    window.removeEventListener('scroll', this.handleScroll);

    if (this.wavesurfer) {
      this.wavesurfer.destroy();
      this.wavesurfer = null;
    }
  }

  _updateWaveform () {
    const { src, height, duration, peaks, preload } = this.props;

    const progressColor = window.getComputedStyle(document.querySelector('.audio-player__progress-placeholder')).getPropertyValue('background-color');
    const waveColor     = window.getComputedStyle(document.querySelector('.audio-player__wave-placeholder')).getPropertyValue('background-color');

    if (this.wavesurfer) {
      this.wavesurfer.destroy();
      this.loaded = false;
    }

    const wavesurfer = WaveSurfer.create({
      container: this.waveform,
      height,
      barWidth: 3,
      cursorWidth: 0,
      progressColor,
      waveColor,
      backend: 'MediaElement',
      interact: preload,
    });

    wavesurfer.setVolume(this.state.volume);

    if (preload) {
      wavesurfer.load(src);
      this.loaded = true;
    } else {
      wavesurfer.load(src, peaks, 'none', duration);
      this.loaded = false;
    }

    wavesurfer.on('ready', () => this.setState({ duration: Math.floor(wavesurfer.getDuration()) }));
    wavesurfer.on('audioprocess', () => this.setState({ currentTime: Math.floor(wavesurfer.getCurrentTime()) }));
    wavesurfer.on('pause', () => this.setState({ paused: true }));
    wavesurfer.on('play', () => this.setState({ paused: false }));
    wavesurfer.on('volume', volume => this.setState({ volume }));
    wavesurfer.on('mute', muted => this.setState({ muted }));

    this.wavesurfer = wavesurfer;
  }

  togglePlay = () => {
    if (this.state.paused) {
      if (!this.props.preload && !this.loaded) {
        this.wavesurfer.createBackend();
        this.wavesurfer.createPeakCache();
        this.wavesurfer.load(this.props.src);
        this.wavesurfer.toggleInteraction();
        this.loaded = true;
      }

      this.setState({ paused: false }, () => this.wavesurfer.play());
    } else {
      this.setState({ paused: true }, () => this.wavesurfer.pause());
    }
  }

  toggleMute = () => {
    const muted = !this.state.muted;
    this.setState({ muted }, () => this.wavesurfer.setMute(muted));
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
    const x    = (e.clientX - rect.left) / this.volWidth; // x position within the element.

    if(!isNaN(x)) {
      let slideamt = x;

      if (x > 1) {
        slideamt = 1;
      } else if(x < 0) {
        slideamt = 0;
      }

      this.wavesurfer.setVolume(slideamt);
    }
  }, 60);

  handleScroll = throttle(() => {
    if (!this.waveform || !this.wavesurfer) {
      return;
    }

    const { top, height } = this.waveform.getBoundingClientRect();
    const inView = (top <= (window.innerHeight || document.documentElement.clientHeight)) && (top + height >= 0);

    if (!this.state.paused && !inView) {
      this.setState({ paused: true }, () => this.wavesurfer.pause());
    }
  }, 150, { trailing: true })

  render () {
    const { height, intl, alt, editable } = this.props;
    const { paused, muted, volume, currentTime } = this.state;

    const volumeWidth     = muted ? 0 : volume * this.volWidth;
    const volumeHandleLoc = muted ? this.volHandleOffset(0) : this.volHandleOffset(volume);

    return (
      <div className={classNames('audio-player', { editable })}>
        <div className='audio-player__progress-placeholder' style={{ display: 'none' }} />
        <div className='audio-player__wave-placeholder' style={{ display: 'none' }} />

        <div
          className='audio-player__waveform'
          aria-label={alt}
          title={alt}
          style={{ height }}
          ref={this.setWaveformRef}
        />

        <div className='video-player__controls active'>
          <div className='video-player__buttons-bar'>
            <div className='video-player__buttons left'>
              <button type='button' title={intl.formatMessage(paused ? messages.play : messages.pause)} aria-label={intl.formatMessage(paused ? messages.play : messages.pause)} onClick={this.togglePlay}><Icon id={paused ? 'play' : 'pause'} fixedWidth /></button>
              <button type='button' title={intl.formatMessage(muted ? messages.unmute : messages.mute)} aria-label={intl.formatMessage(muted ? messages.unmute : messages.mute)} onClick={this.toggleMute}><Icon id={muted ? 'volume-off' : 'volume-up'} fixedWidth /></button>

              <div className='video-player__volume' onMouseDown={this.handleVolumeMouseDown} ref={this.setVolumeRef}>
                &nbsp;
                <div className='video-player__volume__current' style={{ width: `${volumeWidth}px` }} />

                <span
                  className={classNames('video-player__volume__handle')}
                  tabIndex='0'
                  style={{ left: `${volumeHandleLoc}px` }}
                />
              </div>

              <span>
                <span className='video-player__time-current'>{formatTime(currentTime)}</span>
                <span className='video-player__time-sep'>/</span>
                <span className='video-player__time-total'>{formatTime(this.state.duration || Math.floor(this.props.duration))}</span>
              </span>
            </div>

            <div className='video-player__buttons right'>
              <button type='button' title={intl.formatMessage(messages.download)} aria-label={intl.formatMessage(messages.download)}>
                <a className='video-player__download__icon' href={this.props.src} download>
                  <Icon id={'download'} fixedWidth />
                </a>
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

}

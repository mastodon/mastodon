import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';

import classNames from 'classnames';

import { is } from 'immutable';

import { throttle, debounce } from 'lodash';

import { Blurhash } from 'flavours/glitch/components/blurhash';
import { Icon } from 'flavours/glitch/components/icon';
import { formatTime, getPointerPosition, fileNameFromURL } from 'flavours/glitch/features/video';
import { displayMedia, useBlurhash } from 'flavours/glitch/initial_state';

import Visualizer from './visualizer';



const messages = defineMessages({
  play: { id: 'video.play', defaultMessage: 'Play' },
  pause: { id: 'video.pause', defaultMessage: 'Pause' },
  mute: { id: 'video.mute', defaultMessage: 'Mute sound' },
  unmute: { id: 'video.unmute', defaultMessage: 'Unmute sound' },
  download: { id: 'video.download', defaultMessage: 'Download file' },
  hide: { id: 'audio.hide', defaultMessage: 'Hide audio' },
});

const TICK_SIZE = 10;
const PADDING   = 180;

class Audio extends PureComponent {

  static propTypes = {
    src: PropTypes.string.isRequired,
    alt: PropTypes.string,
    lang: PropTypes.string,
    poster: PropTypes.string,
    duration: PropTypes.number,
    width: PropTypes.number,
    height: PropTypes.number,
    sensitive: PropTypes.bool,
    editable: PropTypes.bool,
    fullscreen: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    blurhash: PropTypes.string,
    cacheWidth: PropTypes.func,
    visible: PropTypes.bool,
    onToggleVisibility: PropTypes.func,
    backgroundColor: PropTypes.string,
    foregroundColor: PropTypes.string,
    accentColor: PropTypes.string,
    currentTime: PropTypes.number,
    autoPlay: PropTypes.bool,
    volume: PropTypes.number,
    muted: PropTypes.bool,
    deployPictureInPicture: PropTypes.func,
  };

  state = {
    width: this.props.width,
    currentTime: 0,
    buffer: 0,
    duration: null,
    paused: true,
    muted: false,
    volume: 1,
    dragging: false,
    revealed: this.props.visible !== undefined ? this.props.visible : (displayMedia !== 'hide_all' && !this.props.sensitive || displayMedia === 'show_all'),
  };

  constructor (props) {
    super(props);
    this.visualizer = new Visualizer(TICK_SIZE);
  }

  setPlayerRef = c => {
    this.player = c;

    if (this.player) {
      this._setDimensions();
    }
  };

  _pack() {
    return {
      src: this.props.src,
      volume: this.state.volume,
      muted: this.state.muted,
      currentTime: this.audio.currentTime,
      poster: this.props.poster,
      backgroundColor: this.props.backgroundColor,
      foregroundColor: this.props.foregroundColor,
      accentColor: this.props.accentColor,
      sensitive: this.props.sensitive,
      visible: this.props.visible,
    };
  }

  _setDimensions () {
    const width  = this.player.offsetWidth;
    const height = this.props.fullscreen ? this.player.offsetHeight : (width / (16/9));

    if (width && width !== this.state.containerWidth) {
      if (this.props.cacheWidth) {
        this.props.cacheWidth(width);
      }

      this.setState({ width, height });
    }
  }

  setSeekRef = c => {
    this.seek = c;
  };

  setVolumeRef = c => {
    this.volume = c;
  };

  setAudioRef = c => {
    this.audio = c;

    if (this.audio) {
      this.audio.volume = 1;
      this.audio.muted = false;
    }
  };

  setCanvasRef = c => {
    this.canvas = c;

    this.visualizer.setCanvas(c);
  };

  componentDidMount () {
    window.addEventListener('scroll', this.handleScroll);
    window.addEventListener('resize', this.handleResize, { passive: true });
  }

  componentDidUpdate (prevProps, prevState) {
    if (this.player) {
      this._setDimensions();
    }

    if (prevProps.src !== this.props.src || this.state.width !== prevState.width || this.state.height !== prevState.height || prevProps.accentColor !== this.props.accentColor) {
      this._clear();
      this._draw();
    }
  }

  UNSAFE_componentWillReceiveProps (nextProps) {
    if (!is(nextProps.visible, this.props.visible) && nextProps.visible !== undefined) {
      this.setState({ revealed: nextProps.visible });
    }
  }

  componentWillUnmount () {
    window.removeEventListener('scroll', this.handleScroll);
    window.removeEventListener('resize', this.handleResize);

    if (!this.state.paused && this.audio && this.props.deployPictureInPicture) {
      this.props.deployPictureInPicture('audio', this._pack());
    }
  }

  togglePlay = () => {
    if (!this.audioContext) {
      this._initAudioContext();
    }

    if (this.state.paused) {
      this.setState({ paused: false }, () => this.audio.play());
    } else {
      this.setState({ paused: true }, () => this.audio.pause());
    }
  };

  handleResize = debounce(() => {
    if (this.player) {
      this._setDimensions();
    }
  }, 250, {
    trailing: true,
  });

  handlePlay = () => {
    this.setState({ paused: false });

    if (this.audioContext && this.audioContext.state === 'suspended') {
      this.audioContext.resume();
    }

    this._renderCanvas();
  };

  handlePause = () => {
    this.setState({ paused: true });

    if (this.audioContext) {
      this.audioContext.suspend();
    }
  };

  handleProgress = () => {
    const lastTimeRange = this.audio.buffered.length - 1;

    if (lastTimeRange > -1) {
      this.setState({ buffer: Math.ceil(this.audio.buffered.end(lastTimeRange) / this.audio.duration * 100) });
    }
  };

  toggleMute = () => {
    const muted = !this.state.muted;

    this.setState({ muted }, () => {
      if (this.gainNode) {
        this.gainNode.gain.value = muted ? 0 : this.state.volume;
      }
    });
  };

  toggleReveal = () => {
    if (this.props.onToggleVisibility) {
      this.props.onToggleVisibility();
    } else {
      this.setState({ revealed: !this.state.revealed });
    }
  };

  handleVolumeMouseDown = e => {
    document.addEventListener('mousemove', this.handleMouseVolSlide, true);
    document.addEventListener('mouseup', this.handleVolumeMouseUp, true);
    document.addEventListener('touchmove', this.handleMouseVolSlide, true);
    document.addEventListener('touchend', this.handleVolumeMouseUp, true);

    this.handleMouseVolSlide(e);

    e.preventDefault();
    e.stopPropagation();
  };

  handleVolumeMouseUp = () => {
    document.removeEventListener('mousemove', this.handleMouseVolSlide, true);
    document.removeEventListener('mouseup', this.handleVolumeMouseUp, true);
    document.removeEventListener('touchmove', this.handleMouseVolSlide, true);
    document.removeEventListener('touchend', this.handleVolumeMouseUp, true);
  };

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
  };

  handleMouseUp = () => {
    document.removeEventListener('mousemove', this.handleMouseMove, true);
    document.removeEventListener('mouseup', this.handleMouseUp, true);
    document.removeEventListener('touchmove', this.handleMouseMove, true);
    document.removeEventListener('touchend', this.handleMouseUp, true);

    this.setState({ dragging: false });
    this.audio.play();
  };

  handleMouseMove = throttle(e => {
    const { x } = getPointerPosition(this.seek, e);
    const currentTime = this.audio.duration * x;

    if (!isNaN(currentTime)) {
      this.setState({ currentTime }, () => {
        this.audio.currentTime = currentTime;
      });
    }
  }, 15);

  handleTimeUpdate = () => {
    this.setState({
      currentTime: this.audio.currentTime,
      duration: this.audio.duration,
    });
  };

  handleMouseVolSlide = throttle(e => {
    const { x } = getPointerPosition(this.volume, e);

    if(!isNaN(x)) {
      this.setState({ volume: x }, () => {
        if (this.gainNode) {
          this.gainNode.gain.value = this.state.muted ? 0 : x;
        }
      });
    }
  }, 15);

  handleScroll = throttle(() => {
    if (!this.canvas || !this.audio) {
      return;
    }

    const { top, height } = this.canvas.getBoundingClientRect();
    const inView = (top <= (window.innerHeight || document.documentElement.clientHeight)) && (top + height >= 0);

    if (!this.state.paused && !inView) {
      this.audio.pause();

      if (this.props.deployPictureInPicture) {
        this.props.deployPictureInPicture('audio', this._pack());
      }

      this.setState({ paused: true });
    }
  }, 150, { trailing: true });

  handleMouseEnter = () => {
    this.setState({ hovered: true });
  };

  handleMouseLeave = () => {
    this.setState({ hovered: false });
  };

  handleLoadedData = () => {
    const { autoPlay, currentTime } = this.props;

    if (currentTime) {
      this.audio.currentTime = currentTime;
    }

    if (autoPlay) {
      this.togglePlay();
    }
  };

  _initAudioContext () {
    const AudioContext = window.AudioContext || window.webkitAudioContext;
    const context      = new AudioContext();
    const source       = context.createMediaElementSource(this.audio);
    const gainNode     = context.createGain();

    gainNode.gain.value = this.state.muted ? 0 : this.state.volume;

    this.visualizer.setAudioContext(context, source);
    source.connect(gainNode);
    gainNode.connect(context.destination);

    this.audioContext = context;
    this.gainNode = gainNode;
  }

  handleDownload = () => {
    fetch(this.props.src).then(res => res.blob()).then(blob => {
      const element   = document.createElement('a');
      const objectURL = URL.createObjectURL(blob);

      element.setAttribute('href', objectURL);
      element.setAttribute('download', fileNameFromURL(this.props.src));

      document.body.appendChild(element);
      element.click();
      document.body.removeChild(element);

      URL.revokeObjectURL(objectURL);
    }).catch(err => {
      console.error(err);
    });
  };

  _renderCanvas () {
    requestAnimationFrame(() => {
      if (!this.audio) return;

      this.handleTimeUpdate();
      this._clear();
      this._draw();

      if (!this.state.paused) {
        this._renderCanvas();
      }
    });
  }

  _clear() {
    this.visualizer.clear(this.state.width, this.state.height);
  }

  _draw() {
    this.visualizer.draw(this._getCX(), this._getCY(), this._getAccentColor(), this._getRadius(), this._getScaleCoefficient());
  }

  _getRadius () {
    return parseInt((this.state.height || this.props.height) / 2 - PADDING * this._getScaleCoefficient());
  }

  _getScaleCoefficient () {
    return (this.state.height || this.props.height) / 982;
  }

  _getCX() {
    return Math.floor(this.state.width / 2);
  }

  _getCY() {
    return Math.floor((this.state.height || this.props.height) / 2);
  }

  _getAccentColor () {
    return this.props.accentColor || '#ffffff';
  }

  _getBackgroundColor () {
    return this.props.backgroundColor || '#000000';
  }

  _getForegroundColor () {
    return this.props.foregroundColor || '#ffffff';
  }

  seekBy (time) {
    const currentTime = this.audio.currentTime + time;

    if (!isNaN(currentTime)) {
      this.setState({ currentTime }, () => {
        this.audio.currentTime = currentTime;
      });
    }
  }

  handleAudioKeyDown = e => {
    // On the audio element or the seek bar, we can safely use the space bar
    // for playback control because there are no buttons to press

    if (e.key === ' ') {
      e.preventDefault();
      e.stopPropagation();
      this.togglePlay();
    }
  };

  handleKeyDown = e => {
    switch(e.key) {
    case 'k':
      e.preventDefault();
      e.stopPropagation();
      this.togglePlay();
      break;
    case 'm':
      e.preventDefault();
      e.stopPropagation();
      this.toggleMute();
      break;
    case 'j':
      e.preventDefault();
      e.stopPropagation();
      this.seekBy(-10);
      break;
    case 'l':
      e.preventDefault();
      e.stopPropagation();
      this.seekBy(10);
      break;
    }
  };

  render () {
    const { src, intl, alt, lang, editable, autoPlay, sensitive, blurhash } = this.props;
    const { paused, muted, volume, currentTime, duration, buffer, dragging, revealed } = this.state;
    const progress = Math.min((currentTime / duration) * 100, 100);

    let warning;
    if (sensitive) {
      warning = <FormattedMessage id='status.sensitive_warning' defaultMessage='Sensitive content' />;
    } else {
      warning = <FormattedMessage id='status.media_hidden' defaultMessage='Media hidden' />;
    }

    return (
      <div className={classNames('audio-player', { editable, inactive: !revealed })} ref={this.setPlayerRef} style={{ backgroundColor: this._getBackgroundColor(), color: this._getForegroundColor(), aspectRatio: '16 / 9' }} onMouseEnter={this.handleMouseEnter} onMouseLeave={this.handleMouseLeave} tabIndex={0} onKeyDown={this.handleKeyDown}>

        <Blurhash
          hash={blurhash}
          className={classNames('media-gallery__preview', {
            'media-gallery__preview--hidden': revealed,
          })}
          dummy={!useBlurhash}
        />

        {(revealed || editable) && <audio
          src={src}
          ref={this.setAudioRef}
          preload={autoPlay ? 'auto' : 'none'}
          onPlay={this.handlePlay}
          onPause={this.handlePause}
          onProgress={this.handleProgress}
          onLoadedData={this.handleLoadedData}
          crossOrigin='anonymous'
        />}

        <canvas
          role='button'
          tabIndex={0}
          className='audio-player__canvas'
          width={this.state.width}
          height={this.state.height}
          style={{ width: '100%', position: 'absolute', top: 0, left: 0 }}
          ref={this.setCanvasRef}
          onClick={this.togglePlay}
          onKeyDown={this.handleAudioKeyDown}
          title={alt}
          aria-label={alt}
          lang={lang}
        />

        <div className={classNames('spoiler-button', { 'spoiler-button--hidden': revealed || editable })}>
          <button type='button' className='spoiler-button__overlay' onClick={this.toggleReveal}>
            <span className='spoiler-button__overlay__label'>{warning}</span>
          </button>
        </div>

        {(revealed || editable) && <img
          src={this.props.poster}
          alt=''
          style={{
            position: 'absolute',
            left: '50%',
            top: '50%',
            height: `calc(${(100 - 2 * 100 * PADDING / 982)}% - ${TICK_SIZE * 2}px)`,
            aspectRatio: '1',
            transform: 'translate(-50%, -50%)',
            borderRadius: '50%',
            pointerEvents: 'none',
          }}
        />}

        <div className='video-player__seek' onMouseDown={this.handleMouseDown} ref={this.setSeekRef}>
          <div className='video-player__seek__buffer' style={{ width: `${buffer}%` }} />
          <div className='video-player__seek__progress' style={{ width: `${progress}%`, backgroundColor: this._getAccentColor() }} />

          <span
            className={classNames('video-player__seek__handle', { active: dragging })}
            tabIndex={0}
            style={{ left: `${progress}%`, backgroundColor: this._getAccentColor() }}
            onKeyDown={this.handleAudioKeyDown}
          />
        </div>

        <div className='video-player__controls active'>
          <div className='video-player__buttons-bar'>
            <div className='video-player__buttons left'>
              <button type='button' title={intl.formatMessage(paused ? messages.play : messages.pause)} aria-label={intl.formatMessage(paused ? messages.play : messages.pause)} className='player-button' onClick={this.togglePlay}><Icon id={paused ? 'play' : 'pause'} fixedWidth /></button>
              <button type='button' title={intl.formatMessage(muted ? messages.unmute : messages.mute)} aria-label={intl.formatMessage(muted ? messages.unmute : messages.mute)} className='player-button' onClick={this.toggleMute}><Icon id={muted ? 'volume-off' : 'volume-up'} fixedWidth /></button>

              <div className={classNames('video-player__volume', { active: this.state.hovered })} ref={this.setVolumeRef} onMouseDown={this.handleVolumeMouseDown}>
                <div className='video-player__volume__current' style={{ width: `${volume * 100}%`, backgroundColor: this._getAccentColor() }} />

                <span
                  className='video-player__volume__handle'
                  tabIndex={0}
                  style={{ left: `${volume * 100}%`, backgroundColor: this._getAccentColor() }}
                />
              </div>

              <span className='video-player__time'>
                <span className='video-player__time-current'>{formatTime(Math.floor(currentTime))}</span>
                <span className='video-player__time-sep'>/</span>
                <span className='video-player__time-total'>{formatTime(Math.floor(this.state.duration || this.props.duration))}</span>
              </span>
            </div>

            <div className='video-player__buttons right'>
              {!editable && <button type='button' title={intl.formatMessage(messages.hide)} aria-label={intl.formatMessage(messages.hide)} className='player-button' onClick={this.toggleReveal}><Icon id='eye-slash' fixedWidth /></button>}
              <a title={intl.formatMessage(messages.download)} aria-label={intl.formatMessage(messages.download)} className='video-player__download__icon player-button' href={this.props.src} download>
                <Icon id={'download'} fixedWidth />
              </a>
            </div>
          </div>
        </div>
      </div>
    );
  }

}

export default injectIntl(Audio);

import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import { formatTime } from 'mastodon/features/video';
import Icon from 'mastodon/components/icon';
import classNames from 'classnames';
import { throttle } from 'lodash';
import { encode, decode } from 'blurhash';
import { getPointerPosition, fileNameFromURL } from 'mastodon/features/video';
import { debounce } from 'lodash';

const digitCharacters = [
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z',
  '#',
  '$',
  '%',
  '*',
  '+',
  ',',
  '-',
  '.',
  ':',
  ';',
  '=',
  '?',
  '@',
  '[',
  ']',
  '^',
  '_',
  '{',
  '|',
  '}',
  '~',
];

const decode83 = (str) => {
  let value = 0;
  let c, digit;

  for (let i = 0; i < str.length; i++) {
    c = str[i];
    digit = digitCharacters.indexOf(c);
    value = value * 83 + digit;
  }

  return value;
};

const decodeRGB = int => ({
  r: Math.max(0, (int >> 16)),
  g: Math.max(0, (int >> 8) & 255),
  b: Math.max(0, (int & 255)),
});

const luma = ({ r, g, b }) => 0.2126 * r + 0.7152 * g + 0.0722 * b;

const adjustColor = ({ r, g, b }, lumaThreshold = 100) => {
  let delta;

  if (luma({ r, g, b }) >= lumaThreshold) {
    delta = -80;
  } else {
    delta = 80;
  }

  return {
    r: r + delta,
    g: g + delta,
    b: b + delta,
  };
};

const messages = defineMessages({
  play: { id: 'video.play', defaultMessage: 'Play' },
  pause: { id: 'video.pause', defaultMessage: 'Pause' },
  mute: { id: 'video.mute', defaultMessage: 'Mute sound' },
  unmute: { id: 'video.unmute', defaultMessage: 'Unmute sound' },
  download: { id: 'video.download', defaultMessage: 'Download file' },
});

const TICK_SIZE = 10;
const PADDING   = 180;

export default @injectIntl
class Audio extends React.PureComponent {

  static propTypes = {
    src: PropTypes.string.isRequired,
    alt: PropTypes.string,
    poster: PropTypes.string,
    duration: PropTypes.number,
    width: PropTypes.number,
    height: PropTypes.number,
    editable: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    cacheWidth: PropTypes.func,
  };

  state = {
    width: this.props.width,
    currentTime: 0,
    buffer: 0,
    duration: null,
    paused: true,
    muted: false,
    volume: 0.5,
    dragging: false,
    color: { r: 255, g: 255, b: 255 },
  };

  setPlayerRef = c => {
    this.player = c;

    if (this.player) {
      this._setDimensions();
    }
  }

  _setDimensions () {
    const width  = this.player.offsetWidth;
    const height = width / (16/9);

    if (this.props.cacheWidth) {
      this.props.cacheWidth(width);
    }

    this.setState({ width, height });
  }

  setSeekRef = c => {
    this.seek = c;
  }

  setVolumeRef = c => {
    this.volume = c;
  }

  setAudioRef = c => {
    this.audio = c;

    if (this.audio) {
      this.setState({ volume: this.audio.volume, muted: this.audio.muted });
    }
  }

  setBlurhashCanvasRef = c => {
    this.blurhashCanvas = c;
  }

  setCanvasRef = c => {
    this.canvas = c;

    if (c) {
      this.canvasContext = c.getContext('2d');
    }
  }

  componentDidMount () {
    window.addEventListener('scroll', this.handleScroll);
    window.addEventListener('resize', this.handleResize, { passive: true });

    const img = new Image();
    img.crossOrigin = 'anonymous';
    img.onload = () => this.handlePosterLoad(img);
    img.src = this.props.poster;
  }

  componentDidUpdate (prevProps, prevState) {
    if (prevProps.poster !== this.props.poster) {
      const img = new Image();
      img.crossOrigin = 'anonymous';
      img.onload = () => this.handlePosterLoad(img);
      img.src = this.props.poster;
    }

    if (prevState.blurhash !== this.state.blurhash) {
      const context = this.blurhashCanvas.getContext('2d');
      const pixels = decode(this.state.blurhash, 32, 32);
      const outputImageData = new ImageData(pixels, 32, 32);

      context.putImageData(outputImageData, 0, 0);
    }

    this._clear();
    this._draw();
  }

  componentWillUnmount () {
    window.removeEventListener('scroll', this.handleScroll);
    window.removeEventListener('resize', this.handleResize);
  }

  togglePlay = () => {
    if (this.state.paused) {
      this.setState({ paused: false }, () => this.audio.play());
    } else {
      this.setState({ paused: true }, () => this.audio.pause());
    }
  }

  handleResize = debounce(() => {
    if (this.player) {
      this._setDimensions();
    }
  }, 250, {
    trailing: true,
  });

  handlePlay = () => {
    this.setState({ paused: false });

    if (this.canvas && !this.audioContext) {
      this._initAudioContext();
    }

    if (this.audioContext && this.audioContext.state === 'suspended') {
      this.audioContext.resume();
    }

    this._renderCanvas();
  }

  handlePause = () => {
    this.setState({ paused: true });

    if (this.audioContext) {
      this.audioContext.suspend();
    }
  }

  handleProgress = () => {
    if (this.audio.buffered.length > 0) {
      this.setState({ buffer: this.audio.buffered.end(0) / this.audio.duration * 100 });
    }
  }

  toggleMute = () => {
    const muted = !this.state.muted;

    this.setState({ muted }, () => {
      this.audio.muted = muted;
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
      this.setState({ currentTime }, () => {
        this.audio.currentTime = currentTime;
      });
    }
  }, 60);

  handleTimeUpdate = () => {
    this.setState({
      currentTime: Math.floor(this.audio.currentTime),
      duration: Math.floor(this.audio.duration),
    });
  }

  handleMouseVolSlide = throttle(e => {
    const { x } = getPointerPosition(this.volume, e);

    if(!isNaN(x)) {
      this.setState({ volume: x }, () => {
        this.audio.volume = x;
      });
    }
  }, 60);

  handleScroll = throttle(() => {
    if (!this.canvas || !this.audio) {
      return;
    }

    const { top, height } = this.canvas.getBoundingClientRect();
    const inView = (top <= (window.innerHeight || document.documentElement.clientHeight)) && (top + height >= 0);

    if (!this.state.paused && !inView) {
      this.setState({ paused: true }, () => this.audio.pause());
    }
  }, 150, { trailing: true });

  handleMouseEnter = () => {
    this.setState({ hovered: true });
  }

  handleMouseLeave = () => {
    this.setState({ hovered: false });
  }

  _initAudioContext () {
    const context  = new AudioContext();
    const analyser = context.createAnalyser();
    const source   = context.createMediaElementSource(this.audio);

    analyser.smoothingTimeConstant = 0.6;
    analyser.fftSize = 2048;

    source.connect(analyser);
    source.connect(context.destination);

    this.audioContext = context;
    this.analyser = analyser;
  }

  handlePosterLoad = image => {
    const canvas = document.createElement('canvas');
    const context = canvas.getContext('2d');

    canvas.width  = image.width;
    canvas.height = image.height;

    context.drawImage(image, 0, 0);

    const inputImageData = context.getImageData(0, 0, image.width, image.height);
    const blurhash = encode(inputImageData.data, image.width, image.height, 4, 4);
    const averageColor = decodeRGB(decode83(blurhash.slice(2, 6)));

    this.setState({
      blurhash,
      color: adjustColor(averageColor),
      darkText: luma(averageColor) >= 165,
    });
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
  }

  _renderCanvas () {
    requestAnimationFrame(() => {
      this._clear();
      this._draw();

      if (!this.state.paused) {
        this._renderCanvas();
      }
    });
  }

  _clear () {
    this.canvasContext.clearRect(0, 0, this.state.width, this.state.height);
  }

  _draw () {
    this.canvasContext.save();

    const ticks = this._getTicks(360 * this._getScaleCoefficient(), TICK_SIZE);

    ticks.forEach(tick => {
      this._drawTick(tick.x1, tick.y1, tick.x2, tick.y2);
    });

    this.canvasContext.restore();
  }

  _getRadius () {
    return parseInt(((this.state.height || this.props.height) - (PADDING * this._getScaleCoefficient()) * 2) / 2);
  }

  _getScaleCoefficient () {
    return (this.state.height || this.props.height) / 982;
  }

  _getTicks (count, size, animationParams = [0, 90]) {
    const radius = this._getRadius();
    const ticks = this._getTickPoints(count);
    const lesser = 200;
    const m = [];
    const bufferLength = this.analyser ? this.analyser.frequencyBinCount : 0;
    const frequencyData = new Uint8Array(bufferLength);
    const allScales = [];
    const scaleCoefficient = this._getScaleCoefficient();

    if (this.analyser) {
      this.analyser.getByteFrequencyData(frequencyData);
    }

    ticks.forEach((tick, i) => {
      const coef = 1 - i / (ticks.length * 2.5);

      let delta = ((frequencyData[i] || 0) - lesser * coef) * scaleCoefficient;

      if (delta < 0) {
        delta = 0;
      }

      let k;

      if (animationParams[0] <= tick.angle && tick.angle <= animationParams[1]) {
        k = radius / (radius - this._getSize(tick.angle, animationParams[0], animationParams[1]) - delta);
      } else {
        k = radius / (radius - (size + delta));
      }

      const x1 = tick.x * (radius - size);
      const y1 = tick.y * (radius - size);
      const x2 = x1 * k;
      const y2 = y1 * k;

      m.push({ x1, y1, x2, y2 });

      if (i < 20) {
        let scale = delta / (200 * scaleCoefficient);
        scale = scale < 1 ? 1 : scale;
        allScales.push(scale);
      }
    });

    const scale = allScales.reduce((pv, cv) => pv + cv, 0) / allScales.length;

    return m.map(({ x1, y1, x2, y2 }) => ({
      x1: x1,
      y1: y1,
      x2: x2 * scale,
      y2: y2 * scale,
    }));
  }

  _getSize (angle, l, r) {
    const scaleCoefficient = this._getScaleCoefficient();
    const maxTickSize = TICK_SIZE * 9 * scaleCoefficient;
    const m = (r - l) / 2;
    const x = (angle - l);

    let h;

    if (x === m) {
      return maxTickSize;
    }

    const d = Math.abs(m - x);
    const v = 40 * Math.sqrt(1 / d);

    if (v > maxTickSize) {
      h = maxTickSize;
    } else {
      h = Math.max(TICK_SIZE, v);
    }

    return h;
  }

  _getTickPoints (count) {
    const PI = 360;
    const coords = [];
    const step = PI / count;

    let rad;

    for(let deg = 0; deg < PI; deg += step) {
      rad = deg * Math.PI / (PI / 2);
      coords.push({ x: Math.cos(rad), y: -Math.sin(rad), angle: deg });
    }

    return coords;
  }

  _drawTick (x1, y1, x2, y2) {
    const radius = this._getRadius();
    const cx = this._getCX();
    const cy = this._getCY();

    const dx1 = Math.ceil(cx + x1);
    const dy1 = Math.ceil(cy + y1);
    const dx2 = Math.ceil(cx + x2);
    const dy2 = Math.ceil(cy + y2);

    const gradient = this.canvasContext.createLinearGradient(dx1, dy1, dx2, dy2);

    const mainColor = `rgb(${this.state.color.r}, ${this.state.color.g}, ${this.state.color.b})`;
    const lastColor = `rgba(${this.state.color.r}, ${this.state.color.g}, ${this.state.color.b}, 0)`;

    gradient.addColorStop(0, mainColor);
    gradient.addColorStop(0.6, mainColor);
    gradient.addColorStop(1, lastColor);

    this.canvasContext.beginPath();
    this.canvasContext.strokeStyle = gradient;
    this.canvasContext.lineWidth = 2;
    this.canvasContext.moveTo(dx1, dy1);
    this.canvasContext.lineTo(dx2, dy2);
    this.canvasContext.stroke();
  }

  _getCX() {
    return Math.floor(this.state.width / 2);
  }

  _getCY() {
    return Math.floor(this._getRadius() + (PADDING * this._getScaleCoefficient()));
  }

  _getColor () {
    return `rgb(${this.state.color.r}, ${this.state.color.g}, ${this.state.color.b})`;
  }

  render () {
    const { src, intl, alt, editable } = this.props;
    const { paused, muted, volume, currentTime, duration, buffer, darkText, dragging } = this.state;
    const progress = (currentTime / duration) * 100;

    return (
      <div className={classNames('audio-player', { editable, 'with-light-background': darkText })} ref={this.setPlayerRef} style={{ width: '100%', height: this.state.height || this.props.height }} onMouseEnter={this.handleMouseEnter} onMouseLeave={this.handleMouseLeave}>
        <audio
          src={src}
          ref={this.setAudioRef}
          preload='none'
          onPlay={this.handlePlay}
          onPause={this.handlePause}
          onProgress={this.handleProgress}
          onTimeUpdate={this.handleTimeUpdate}
          crossOrigin='anonymous'
        />

        <canvas
          className='audio-player__background'
          onClick={this.togglePlay}
          width='32'
          height='32'
          style={{ width: this.state.width, height: this.state.height, position: 'absolute', top: 0, left: 0 }}
          ref={this.setBlurhashCanvasRef}
          aria-label={alt}
          title={alt}
          role='button'
          tabIndex='0'
        />

        <canvas
          className='audio-player__canvas'
          width={this.state.width}
          height={this.state.height}
          style={{ width: '100%', position: 'absolute', top: 0, left: 0, pointerEvents: 'none' }}
          ref={this.setCanvasRef}
        />

        <img
          src={this.props.poster}
          alt=''
          width={(this._getRadius() - TICK_SIZE) * 2}
          height={(this._getRadius() - TICK_SIZE) * 2}
          style={{ position: 'absolute', left: this._getCX(), top: this._getCY(), transform: 'translate(-50%, -50%)', borderRadius: '50%', pointerEvents: 'none' }}
        />

        <div className='video-player__seek' onMouseDown={this.handleMouseDown} ref={this.setSeekRef}>
          <div className='video-player__seek__buffer' style={{ width: `${buffer}%` }} />
          <div className='video-player__seek__progress' style={{ width: `${progress}%`, backgroundColor: this._getColor() }} />

          <span
            className={classNames('video-player__seek__handle', { active: dragging })}
            tabIndex='0'
            style={{ left: `${progress}%`, backgroundColor: this._getColor() }}
          />
        </div>

        <div className='video-player__controls active'>
          <div className='video-player__buttons-bar'>
            <div className='video-player__buttons left'>
              <button type='button' title={intl.formatMessage(paused ? messages.play : messages.pause)} aria-label={intl.formatMessage(paused ? messages.play : messages.pause)} onClick={this.togglePlay}><Icon id={paused ? 'play' : 'pause'} fixedWidth /></button>
              <button type='button' title={intl.formatMessage(muted ? messages.unmute : messages.mute)} aria-label={intl.formatMessage(muted ? messages.unmute : messages.mute)} onClick={this.toggleMute}><Icon id={muted ? 'volume-off' : 'volume-up'} fixedWidth /></button>

              <div className={classNames('video-player__volume', { active: this.state.hovered })} ref={this.setVolumeRef} onMouseDown={this.handleVolumeMouseDown}>
                <div className='video-player__volume__current' style={{ width: `${volume * 100}%`, backgroundColor: this._getColor() }} />

                <span
                  className={classNames('video-player__volume__handle')}
                  tabIndex='0'
                  style={{ left: `${volume * 100}%`, backgroundColor: this._getColor() }}
                />
              </div>

              <span className='video-player__time'>
                <span className='video-player__time-current'>{formatTime(currentTime)}</span>
                <span className='video-player__time-sep'>/</span>
                <span className='video-player__time-total'>{formatTime(this.state.duration || Math.floor(this.props.duration))}</span>
              </span>
            </div>

            <div className='video-player__buttons right'>
              <button type='button' title={intl.formatMessage(messages.download)} aria-label={intl.formatMessage(messages.download)} onClick={this.handleDownload}><Icon id='download' fixedWidth /></button>
            </div>
          </div>
        </div>
      </div>
    );
  }

}

import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';

const MIN_SCALE = 1;
const MAX_SCALE = 4;

const getMidpoint = (p1, p2) => ({
  x: (p1.clientX + p2.clientX) / 2,
  y: (p1.clientY + p2.clientY) / 2,
});

const getDistance = (p1, p2) =>
  Math.sqrt(Math.pow(p1.clientX - p2.clientX, 2) + Math.pow(p1.clientY - p2.clientY, 2));

const between = (min, max, value) => Math.min(max, Math.max(min, value));

export default class ImageLoader extends React.PureComponent {

  static propTypes = {
    alt: PropTypes.string,
    src: PropTypes.string.isRequired,
    previewSrc: PropTypes.string,
    width: PropTypes.number,
    height: PropTypes.number,
    onClick: PropTypes.func,
  }

  static defaultProps = {
    alt: '',
    width: null,
    height: null,
  };

  state = {
    loading: true,
    error: false,
    scale: MIN_SCALE,
  }

  removers = [];
  container = null;
  canvas = null;
  image = null;
  lastTouchEndTime = 0;
  lastDistance = 0;

  get canvasContext() {
    if (!this.canvas) {
      return null;
    }
    this._canvasContext = this._canvasContext || this.canvas.getContext('2d');
    return this._canvasContext;
  }

  componentDidMount () {
    // TODO register to removers
    this.container.addEventListener('touchstart', this.handleTouchStart.bind(this));
    // on Chrome 56+, touch event listeners will default to passive
    // https://www.chromestatus.com/features/5093566007214080
    this.container.addEventListener('touchmove', this.handleTouchMove.bind(this), { passive: false });

    this.loadImage(this.props);
  }

  componentWillReceiveProps (nextProps) {
    if (this.props.src !== nextProps.src) {
      this.loadImage(nextProps);
    }
  }

  componentWillUnmount () {
    this.removeEventListeners();
  }

  loadImage (props) {
    this.removeEventListeners();
    this.setState({ loading: true, error: false });
    Promise.all([
      props.previewSrc && this.loadPreviewCanvas(props),
      this.hasSize() && this.loadOriginalImage(props),
    ].filter(Boolean))
      .then(() => {
        this.setState({ loading: false, error: false });
        this.clearPreviewCanvas();
      })
      .catch(() => this.setState({ loading: false, error: true }));
  }

  loadPreviewCanvas = ({ previewSrc, width, height }) => new Promise((resolve, reject) => {
    const image = new Image();
    const removeEventListeners = () => {
      image.removeEventListener('error', handleError);
      image.removeEventListener('load', handleLoad);
    };
    const handleError = () => {
      removeEventListeners();
      reject();
    };
    const handleLoad = () => {
      removeEventListeners();
      this.canvasContext.drawImage(image, 0, 0, width, height);
      resolve();
    };
    image.addEventListener('error', handleError);
    image.addEventListener('load', handleLoad);
    image.src = previewSrc;
    this.removers.push(removeEventListeners);
  })

  clearPreviewCanvas () {
    const { width, height } = this.canvas;
    this.canvasContext.clearRect(0, 0, width, height);
  }

  loadOriginalImage = ({ src }) => new Promise((resolve, reject) => {
    const image = new Image();
    const removeEventListeners = () => {
      image.removeEventListener('error', handleError);
      image.removeEventListener('load', handleLoad);
    };
    const handleError = () => {
      removeEventListeners();
      reject();
    };
    const handleLoad = () => {
      removeEventListeners();
      resolve();
    };
    image.addEventListener('error', handleError);
    image.addEventListener('load', handleLoad);
    image.src = src;
    this.removers.push(removeEventListeners);
  });

  removeEventListeners () {
    this.removers.forEach(listeners => listeners());
    this.removers = [];
  }

  hasSize () {
    const { width, height } = this.props;
    return typeof width === 'number' && typeof height === 'number';
  }

  handleTouchStart = ev => {
    if (ev.touches.length !== 2) return;

    this.lastDistance = getDistance(...ev.touches);
  }

  handleTouchMove = ev => {
    const { scrollTop, scrollHeight, clientHeight } = this.container;
    if (ev.touches.length === 1
      && scrollTop !== scrollHeight - clientHeight) {
      // prevent propagating event to MediaModal
      ev.stopPropagation();
      return;
    }
    if (ev.touches.length !== 2) return;

    ev.preventDefault();
    ev.stopPropagation();

    const distance = getDistance(...ev.touches);
    const midpoint = getMidpoint(...ev.touches);
    const scale = between(MIN_SCALE, MAX_SCALE, this.state.scale * distance / this.lastDistance);

    this.zoom(scale, midpoint);

    this.lastMidpoint = midpoint;
    this.lastDistance = distance;
  }

  zoom(nextScale, midpoint) {
    const { scale } = this.state;
    const { scrollLeft, scrollTop } = this.container;

    // math memo:
    // x = (scrollLeft + midpoint.x) / scrollWidth
    // x' = (nextScrollLeft + midpoint.x) / nextScrollWidth
    // scrollWidth = clientWidth * scale
    // scrollWidth' = clientWidth * nextScale
    // Solve x = x' for nextScrollLeft
    const nextScrollLeft = (scrollLeft + midpoint.x) * nextScale / scale - midpoint.x;
    const nextScrollTop = (scrollTop + midpoint.y) * nextScale / scale - midpoint.y;

    // this.container.scrollLeft = nextScrollLeft;
    // this.container.scrollTop = nextScrollTop;

    this.setState({ scale: nextScale }, () => {
      // callback
      this.container.scrollLeft = nextScrollLeft;
      this.container.scrollTop = nextScrollTop;
    });
  }

  handleClick = ev => {
    // don't propagate event to MediaModal
    ev.stopPropagation();
    const handler = this.props.onClick;
    if (handler) handler();
  }

  render () {
    const { alt, src, width, height } = this.props;
    const { loading, scale } = this.state;
    const overflow = scale === 1 ? 'hidden' : 'scroll';

    const className = classNames('image-loader', {
      'image-loader--loading': loading,
      'image-loader--amorphous': !this.hasSize(),
    });

    const setContainerRef = c => {
      this.container = c;
    };
    const setCanvasRef = c => {
      this.canvas = c;
    };
    const setImageRef = c => {
      this.image = c;
    };

    return (
      <div
        className={className}
        ref={setContainerRef}
        style={{
          height: `${document.body.clientHeight}px`,
          overflow,
        }}
      >
        {loading && (
          <canvas
            className='image-loader__preview-canvas'
            ref={setCanvasRef}
            width={width}
            height={height}
          />
        )}
        {!loading && (
          <img
            className='image-loader__img'
            role='presentation'
            ref={setImageRef}
            alt={alt}
            src={src}
            width={width}
            height={height}
            style={{
              transform: `scale(${scale})`,
              transformOrigin: '0 0',
            }}
            onClick={this.handleClick}
          />
        )}
      </div>
    );
  }

}

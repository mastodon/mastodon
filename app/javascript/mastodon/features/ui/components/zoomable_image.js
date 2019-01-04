import React from 'react';
import PropTypes from 'prop-types';

const MIN_SCALE = 1;
const MAX_SCALE = 4;

const getMidpoint = (p1, p2) => ({
  x: (p1.clientX + p2.clientX) / 2,
  y: (p1.clientY + p2.clientY) / 2,
});

const getDistance = (p1, p2) =>
  Math.sqrt(Math.pow(p1.clientX - p2.clientX, 2) + Math.pow(p1.clientY - p2.clientY, 2));

const clamp = (min, max, value) => Math.min(max, Math.max(min, value));

export default class ZoomableImage extends React.PureComponent {

  static propTypes = {
    alt: PropTypes.string,
    src: PropTypes.string.isRequired,
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
    scale: MIN_SCALE,
  }

  removers = [];
  container = null;
  image = null;
  lastTouchEndTime = 0;
  lastDistance = 0;

  componentDidMount () {
    let handler = this.handleTouchStart;
    this.container.addEventListener('touchstart', handler);
    this.removers.push(() => this.container.removeEventListener('touchstart', handler));
    handler = this.handleTouchMove;
    // on Chrome 56+, touch event listeners will default to passive
    // https://www.chromestatus.com/features/5093566007214080
    this.container.addEventListener('touchmove', handler, { passive: false });
    this.removers.push(() => this.container.removeEventListener('touchend', handler));
  }

  componentWillUnmount () {
    this.removeEventListeners();
  }

  removeEventListeners () {
    this.removers.forEach(listeners => listeners());
    this.removers = [];
  }

  handleTouchStart = e => {
    if (e.touches.length !== 2) return;

    this.lastDistance = getDistance(...e.touches);
  }

  handleTouchMove = e => {
    const { scrollTop, scrollHeight, clientHeight } = this.container;
    if (e.touches.length === 1 && scrollTop !== scrollHeight - clientHeight) {
      // prevent propagating event to MediaModal
      e.stopPropagation();
      return;
    }
    if (e.touches.length !== 2) return;

    e.preventDefault();
    e.stopPropagation();

    const distance = getDistance(...e.touches);
    const midpoint = getMidpoint(...e.touches);
    const scale = clamp(MIN_SCALE, MAX_SCALE, this.state.scale * distance / this.lastDistance);

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

    this.setState({ scale: nextScale }, () => {
      this.container.scrollLeft = nextScrollLeft;
      this.container.scrollTop = nextScrollTop;
    });
  }

  handleClick = e => {
    // don't propagate event to MediaModal
    e.stopPropagation();
    const handler = this.props.onClick;
    if (handler) handler();
  }

  setContainerRef = c => {
    this.container = c;
  }

  setImageRef = c => {
    this.image = c;
  }

  render () {
    const { alt, src } = this.props;
    const { scale } = this.state;
    const overflow = scale === 1 ? 'hidden' : 'scroll';

    return (
      <div
        className='zoomable-image'
        ref={this.setContainerRef}
        style={{ overflow }}
      >
        <img
          role='presentation'
          ref={this.setImageRef}
          alt={alt}
          src={src}
          style={{
            transform: `scale(${scale})`,
            transformOrigin: '0 0',
          }}
          onClick={this.handleClick}
        />
      </div>
    );
  }

}

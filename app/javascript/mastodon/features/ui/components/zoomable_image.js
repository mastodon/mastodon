import React from 'react';
import PropTypes from 'prop-types';
import Hammer from 'hammerjs';

const MIN_SCALE = 1;
const MAX_SCALE = 4;
const DOUBLE_TAP_SCALE = 2;

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
  lastScale = null;
  zoomCenter = null;

  componentDidMount () {
    // register pinch event handlers to the container
    let hammer = new Hammer.Manager(this.container, {
      // required to make container scrollable by touch
      touchAction: 'pan-x pan-y',
    });
    hammer.add(new Hammer.Pinch());
    hammer.on('pinchstart', this.handlePinchStart);
    hammer.on('pinchmove', this.handlePinchMove);
    this.removers.push(() => hammer.off('pinchstart pinchmove'));

    // register tap event handlers
    hammer = new Hammer.Manager(this.image);
    // NOTE the order of adding is also the order of gesture recognition
    hammer.add(new Hammer.Tap({ event: 'doubletap', taps: 2 }));
    hammer.add(new Hammer.Tap());
    // prevent the 'tap' event handler be fired on double tap
    hammer.get('tap').requireFailure('doubletap');
    // NOTE 'tap' and 'doubletap' events are fired by touch and *mouse*
    hammer.on('tap', this.handleTap);
    hammer.on('doubletap', this.handleDoubleTap);
    this.removers.push(() => hammer.off('tap doubletap'));
  }

  componentWillUnmount () {
    this.removeEventListeners();
  }

  componentDidUpdate (prevProps, prevState) {
    if (!this.zoomCenter) return;

    const { x: cx, y: cy } = this.zoomCenter;
    const { scale: prevScale } = prevState;
    const { scale: nextScale } = this.state;
    const { scrollLeft, scrollTop } = this.container;

    // math memo:
    // x = (scrollLeft + cx) / scrollWidth
    // x' = (nextScrollLeft + cx) / nextScrollWidth
    // scrollWidth = clientWidth * prevScale
    // scrollWidth' = clientWidth * nextScale
    // Solve x = x' for nextScrollLeft
    const nextScrollLeft = (scrollLeft + cx) * nextScale / prevScale - cx;
    const nextScrollTop = (scrollTop + cy) * nextScale / prevScale - cy;

    this.container.scrollLeft = nextScrollLeft;
    this.container.scrollTop = nextScrollTop;
  }

  removeEventListeners () {
    this.removers.forEach(listeners => listeners());
    this.removers = [];
  }

  handleClick = e => {
    // prevent the click event propagated to parent
    e.stopPropagation();

    // the tap event handler is executed at the same time by touch and mouse,
    // so we don't need to execute the onClick handler here
  }

  handlePinchStart = () => {
    this.lastScale = this.state.scale;
  }

  handlePinchMove = e => {
    const scale = clamp(MIN_SCALE, MAX_SCALE, this.lastScale * e.scale);
    this.zoom(scale, e.center);
  }

  handleTap = () => {
    const handler = this.props.onClick;
    if (handler) handler();
  }

  handleDoubleTap = e => {
    if (this.state.scale === MIN_SCALE)
      this.zoom(DOUBLE_TAP_SCALE, e.center);
    else
      this.zoom(MIN_SCALE, e.center);
  }

  zoom (scale, center) {
    this.zoomCenter = center;
    this.setState({ scale });
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
    const marginStyle = {
      position: 'absolute',
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      transform: `scale(${scale})`,
      transformOrigin: '0 0',
    };

    return (
      <div
        className='zoomable-image'
        ref={this.setContainerRef}
        style={{ overflow }}
      >
        <div
          className='zoomable-image__margin'
          style={marginStyle}
        >
          <img
            ref={this.setImageRef}
            role='presentation'
            alt={alt}
            src={src}
            onClick={this.handleClick}
          />
        </div>
      </div>
    );
  }

}

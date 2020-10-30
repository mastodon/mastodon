import React from 'react';
import PropTypes from 'prop-types';
import IconButton from 'mastodon/components/icon_button';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  compress: { id: 'lightbox.compress', defaultMessage: 'Compress image view box' },
  expand: { id: 'lightbox.expand', defaultMessage: 'Expand image view box' },
});

const MIN_SCALE = 1;
const MAX_SCALE = 4;
const NAV_BAR_HEIGHT = 66;
const SCROLL_BAR_THICKNESS = 12;

const getMidpoint = (p1, p2) => ({
  x: (p1.clientX + p2.clientX) / 2,
  y: (p1.clientY + p2.clientY) / 2,
});

const getDistance = (p1, p2) =>
  Math.sqrt(Math.pow(p1.clientX - p2.clientX, 2) + Math.pow(p1.clientY - p2.clientY, 2));

const clamp = (min, max, value) => Math.min(max, Math.max(min, value));

export default @injectIntl
class ZoomableImage extends React.PureComponent {

  static propTypes = {
    alt: PropTypes.string,
    src: PropTypes.string.isRequired,
    width: PropTypes.number,
    height: PropTypes.number,
    onClick: PropTypes.func,
    zoomButtonHidden: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  }

  static defaultProps = {
    alt: '',
    width: null,
    height: null,
  };

  state = {
    scale: MIN_SCALE,
    navigationHidden: false,
    zoomState: 'expand',
    pos: { top: 0, left: 0, x: 0, y: 0 },
    dragged: false,
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

    handler = this.mouseDownHandler;
    this.container.addEventListener('mousedown', handler);
    this.removers.push(() => this.container.removeEventListener('mousedown', handler));
  }

  componentWillUnmount () {
    this.removeEventListeners();
  }

  componentDidUpdate () {
    const { clientWidth, clientHeight } = this.container;
    const { offsetWidth, offsetHeight } = this.image;

    if (this.props.zoomButtonHidden) {
      this.setState({ scale: MIN_SCALE }, () => {
        this.container.scrollLeft = 0;
        this.container.scrollTop = 0;
      });
    }

    this.setState({ zoomState: this.state.scale >= Math.max( (clientWidth - 2 * SCROLL_BAR_THICKNESS)/offsetWidth, (clientHeight - NAV_BAR_HEIGHT)/offsetHeight ) ? 'compress' : 'expand' });

    if (this.state.scale === 1) {
      this.container.style.cursor = 'auto';
    } else {
      this.container.style.cursor = 'grab';
    }
  }

  removeEventListeners () {
    this.removers.forEach(listeners => listeners());
    this.removers = [];
  }

  mouseDownHandler = e => {
    this.container.style.cursor = 'grabbing';
    this.container.style.userSelect = 'none';

    this.setState({ pos: {
      left: this.container.scrollLeft,
      top: this.container.scrollTop,
      // Get the current mouse position
      x: e.clientX,
      y: e.clientY,
    } });

    this.image.addEventListener('mousemove', this.mouseMoveHandler);
    this.image.addEventListener('mouseup', this.mouseUpHandler);
  }

  mouseMoveHandler = e => {
    // How far the mouse has been moved
    const dx = e.clientX - this.state.pos.x;
    const dy = e.clientY - this.state.pos.y;

    // Scroll the element
    this.container.scrollTop = this.state.pos.top - dy;
    this.container.scrollLeft = this.state.pos.left - dx;

    this.setState({ dragged: true });
  }

  mouseUpHandler = () => {
    this.container.style.cursor = 'grab';
    this.container.style.removeProperty('user-select');

    this.image.removeEventListener('mousemove', this.mouseMoveHandler);
    this.image.removeEventListener('mouseup', this.mouseUpHandler);
  }

  handleTouchStart = e => {
    if (e.touches.length !== 2) return;

    this.lastDistance = getDistance(...e.touches);
  }

  handleTouchMove = e => {
    const { scrollTop, scrollHeight, clientHeight, clientWidth } = this.container;
    const { offsetWidth, offsetHeight } = this.image;
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
    const _MAX_SCALE = Math.max( MAX_SCALE, (clientWidth - 2 * SCROLL_BAR_THICKNESS)/offsetWidth, (clientHeight - NAV_BAR_HEIGHT)/offsetHeight );
    const scale = clamp(MIN_SCALE, _MAX_SCALE, this.state.scale * distance / this.lastDistance);

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
    const dragged = this.state.dragged;
    this.setState({ dragged: false });
    if (dragged) return;
    const handler = this.props.onClick;
    if (handler) handler();
    this.setState({ navigationHidden: !this.state.navigationHidden });
  }

  handleZoomClick = e => {
    e.preventDefault();
    e.stopPropagation();

    const { width, height } = this.props;
    const { clientWidth, clientHeight } = this.container;
    const { offsetWidth, offsetHeight } = this.image;
    const clientHeightFixed = clientHeight - NAV_BAR_HEIGHT;

    if ( this.state.scale >= Math.max(( clientWidth - 2 * SCROLL_BAR_THICKNESS)/offsetWidth, (clientHeightFixed)/offsetHeight ) ) {
      this.setState({ scale: MIN_SCALE }, () => {
        this.container.scrollLeft = 0;
        this.container.scrollTop = 0;
      });
    } else if ( width/height < clientWidth/clientHeightFixed ) {
      // full width
      this.setState({ scale: clientWidth/offsetWidth }, () => {
        this.container.scrollLeft = (clientWidth-offsetWidth)/2;
        this.container.scrollTop = (clientHeight-offsetHeight)/2 - NAV_BAR_HEIGHT;
      });
    } else {
      // full height
      this.setState({ scale: clientHeightFixed/offsetHeight }, () => {
        this.container.scrollTop = (clientHeightFixed-offsetHeight)/2;
        this.container.scrollLeft = (clientWidth-offsetWidth)/2;
      });
    }
  }

  setContainerRef = c => {
    this.container = c;
  }

  setImageRef = c => {
    this.image = c;
  }

  render () {
    const { alt, src, width, height, intl } = this.props;
    const { scale } = this.state;
    const overflow = scale === 1 ? 'hidden' : 'scroll';
    const zoomButtonSshouldHide = !this.state.navigationHidden && !this.props.zoomButtonHidden ? '' : 'media-modal__zoom-button--hidden';
    const zoomButtonTitle = this.state.zoomState === 'compress' ? intl.formatMessage(messages.compress) : intl.formatMessage(messages.expand);

    return (
      <React.Fragment>
        <IconButton
          className={`media-modal__zoom-button ${zoomButtonSshouldHide}`}
          title={zoomButtonTitle}
          icon={this.state.zoomState}
          onClick={this.handleZoomClick}
          size={40}
          style={{
            fontSize: '30px'
          }} />
        <div
          className='zoomable-image'
          ref={this.setContainerRef}
          style={{ overflow }}
        >
          <img
            role='presentation'
            ref={this.setImageRef}
            alt={alt}
            title={alt}
            src={src}
            width={width}
            height={height}
            style={{
              transform: `scale(${scale})`,
              transformOrigin: '0 0',
            }}
            draggable={false}
            onClick={this.handleClick}
          />
        </div>
      </React.Fragment>
    );
  }

}

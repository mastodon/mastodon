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
// left 10% of button height when expand
const EXPAND_VIEW_HEIGHT = 0.9;
const SCROLL_BAR_SIZE = 12;

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
    zoomState: 'expand'
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

  componentDidUpdate () {
    if (this.props.zoomButtonHidden) {
      this.setState({ scale: MIN_SCALE }, () => {
        this.container.scrollLeft = 0;
        this.container.scrollTop = 0;
      });
    }
    this.setState({ zoomState: this.state.scale >= Math.max((this.container.clientWidth-SCROLL_BAR_SIZE)/this.image.offsetWidth, ((this.container.clientHeight-SCROLL_BAR_SIZE) * EXPAND_VIEW_HEIGHT-SCROLL_BAR_SIZE)/this.image.offsetHeight)? 'compress' : 'expand' });
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
    const _MAX_SCALE = Math.max(MAX_SCALE, (clientWidth-SCROLL_BAR_SIZE)/offsetWidth, ((clientHeight-SCROLL_BAR_SIZE) * EXPAND_VIEW_HEIGHT-SCROLL_BAR_SIZE)/offsetHeight)
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
    const handler = this.props.onClick;
    if (handler) handler();
    this.setState({ navigationHidden: !this.state.navigationHidden })
  }

  handleZoomClick = e => {
    e.preventDefault();
    e.stopPropagation();

    const { width, height } = this.props;
    const { clientWidth, clientHeight } = this.container;
    const { offsetWidth, offsetHeight } = this.image;
    const _clientWidth = clientWidth + SCROLL_BAR_SIZE;
    const _clientHeight = clientHeight - SCROLL_BAR_SIZE;
    const _clientHeightFixed = _clientHeight * EXPAND_VIEW_HEIGHT;

    if ( this.state.scale >= Math.max((clientWidth-SCROLL_BAR_SIZE)/offsetWidth, (_clientHeightFixed-SCROLL_BAR_SIZE)/offsetHeight) ) {
      this.setState({ scale: MIN_SCALE }, () => {
        this.container.scrollLeft = 0;
        this.container.scrollTop = 0;
      });
    } else if ( width/height < _clientWidth/_clientHeightFixed ) {
      // full width
      this.setState({ scale: _clientWidth/offsetWidth }, () => {
        this.container.scrollLeft = (_clientWidth-offsetWidth)/2;
      });
    } else {
      // full height
      this.setState({ scale: _clientHeightFixed/offsetHeight }, () => {
        this.container.scrollTop = (_clientHeightFixed-offsetHeight)/2;
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
          className={ `media-modal__zoom-button ${zoomButtonSshouldHide}` }
          title={zoomButtonTitle} 
          icon={this.state.zoomState}
          onClick={this.handleZoomClick} 
          size={40}
          style={{ fontSize: '30px' }} />
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
            onClick={this.handleClick}
          />
        </div>
      </React.Fragment>
    );
  }

}

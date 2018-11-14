import React, { PureComponent } from 'react';
import { ScrollContainer } from 'react-router-scroll-4';
import PropTypes from 'prop-types';
import IntersectionObserverArticleContainer from '../containers/intersection_observer_article_container';
import LoadMore from './load_more';
import IntersectionObserverWrapper from '../features/ui/util/intersection_observer_wrapper';
import { throttle } from 'lodash';
import { List as ImmutableList } from 'immutable';
import classNames from 'classnames';
import { attachFullscreenListener, detachFullscreenListener, isFullscreen } from '../features/ui/util/fullscreen';
import LoadingIndicator from './loading_indicator';

const MOUSE_IDLE_DELAY = 300;

export default class ScrollableList extends PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    scrollKey: PropTypes.string.isRequired,
    onLoadMore: PropTypes.func,
    onScrollToTop: PropTypes.func,
    onScroll: PropTypes.func,
    trackScroll: PropTypes.bool,
    shouldUpdateScroll: PropTypes.func,
    isLoading: PropTypes.bool,
    showLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    prepend: PropTypes.node,
    alwaysPrepend: PropTypes.bool,
    alwaysShowScrollbar: PropTypes.bool,
    emptyMessage: PropTypes.node,
    children: PropTypes.node,
  };

  static defaultProps = {
    trackScroll: true,
  };

  state = {
    fullscreen: null,
  };

  intersectionObserverWrapper = new IntersectionObserverWrapper();

  handleScroll = throttle(() => {
    if (this.node) {
      const { scrollTop, scrollHeight, clientHeight } = this.node;
      const offset = scrollHeight - scrollTop - clientHeight;

      if (400 > offset && this.props.onLoadMore && !this.props.isLoading) {
        this.props.onLoadMore();
      }

      if (scrollTop < 100 && this.props.onScrollToTop) {
        this.props.onScrollToTop();
      } else if (this.props.onScroll) {
        this.props.onScroll();
      }

      if (!this.lastScrollWasSynthetic) {
        // If the last scroll wasn't caused by setScrollTop(), assume it was
        // intentional and cancel any pending scroll reset on mouse idle
        this.scrollToTopOnMouseIdle = false;
      }
      this.lastScrollWasSynthetic = false;
    }
  }, 150, {
    trailing: true,
  });

  mouseIdleTimer = null;
  mouseMovedRecently = false;
  lastScrollWasSynthetic = false;
  scrollToTopOnMouseIdle = false;

  setScrollTop = newScrollTop => {
    if (this.node.scrollTop !== newScrollTop) {
      this.lastScrollWasSynthetic = true;
      this.node.scrollTop = newScrollTop;
    }
  };

  clearMouseIdleTimer = () => {
    if (this.mouseIdleTimer === null) {
      return;
    }

    clearTimeout(this.mouseIdleTimer);
    this.mouseIdleTimer = null;
  };

  handleMouseMove = throttle(() => {
    // As long as the mouse keeps moving, clear and restart the idle timer.
    this.clearMouseIdleTimer();
    this.mouseIdleTimer = setTimeout(this.handleMouseIdle, MOUSE_IDLE_DELAY);

    if (!this.mouseMovedRecently && this.node.scrollTop === 0) {
      // Only set if we just started moving and are scrolled to the top.
      this.scrollToTopOnMouseIdle = true;
    }

    // Save setting this flag for last, so we can do the comparison above.
    this.mouseMovedRecently = true;
  }, MOUSE_IDLE_DELAY / 2);

  handleWheel = throttle(() => {
    this.scrollToTopOnMouseIdle = false;
  }, 150, {
    trailing: true,
  });

  handleMouseIdle = () => {
    if (this.scrollToTopOnMouseIdle) {
      this.setScrollTop(0);
    }

    this.mouseMovedRecently = false;
    this.scrollToTopOnMouseIdle = false;
  }

  componentDidMount () {
    this.attachScrollListener();
    this.attachIntersectionObserver();

    attachFullscreenListener(this.onFullScreenChange);

    // Handle initial scroll posiiton
    this.handleScroll();
  }

  getSnapshotBeforeUpdate (prevProps) {
    const someItemInserted = React.Children.count(prevProps.children) > 0 &&
      React.Children.count(prevProps.children) < React.Children.count(this.props.children) &&
      this.getFirstChildKey(prevProps) !== this.getFirstChildKey(this.props);

    if (someItemInserted && (this.node.scrollTop > 0 || this.mouseMovedRecently)) {
      return this.node.scrollHeight - this.node.scrollTop;
    } else {
      return null;
    }
  }

  componentDidUpdate (prevProps, prevState, snapshot) {
    // Reset the scroll position when a new child comes in in order not to
    // jerk the scrollbar around if you're already scrolled down the page.
    if (snapshot !== null) {
      this.setScrollTop(this.node.scrollHeight - snapshot);
    }
  }

  componentWillUnmount () {
    this.clearMouseIdleTimer();
    this.detachScrollListener();
    this.detachIntersectionObserver();
    detachFullscreenListener(this.onFullScreenChange);
  }

  onFullScreenChange = () => {
    this.setState({ fullscreen: isFullscreen() });
  }

  attachIntersectionObserver () {
    this.intersectionObserverWrapper.connect({
      root: this.node,
      rootMargin: '300% 0px',
    });
  }

  detachIntersectionObserver () {
    this.intersectionObserverWrapper.disconnect();
  }

  attachScrollListener () {
    this.node.addEventListener('scroll', this.handleScroll);
    this.node.addEventListener('wheel', this.handleWheel);
  }

  detachScrollListener () {
    this.node.removeEventListener('scroll', this.handleScroll);
    this.node.removeEventListener('wheel', this.handleWheel);
  }

  getFirstChildKey (props) {
    const { children } = props;
    let firstChild     = children;

    if (children instanceof ImmutableList) {
      firstChild = children.get(0);
    } else if (Array.isArray(children)) {
      firstChild = children[0];
    }

    return firstChild && firstChild.key;
  }

  setRef = (c) => {
    this.node = c;
  }

  handleLoadMore = e => {
    e.preventDefault();
    this.props.onLoadMore();
  }

  render () {
    const { children, scrollKey, trackScroll, shouldUpdateScroll, showLoading, isLoading, hasMore, prepend, alwaysPrepend, alwaysShowScrollbar, emptyMessage, onLoadMore } = this.props;
    const { fullscreen } = this.state;
    const childrenCount = React.Children.count(children);

    const loadMore     = (hasMore && childrenCount > 0 && onLoadMore) ? <LoadMore visible={!isLoading} onClick={this.handleLoadMore} /> : null;
    let scrollableArea = null;

    if (showLoading) {
      scrollableArea = (
        <div className='scrollable scrollable--flex' ref={this.setRef}>
          <div role='feed' className='item-list'>
            {prepend}
          </div>

          <div className='scrollable__append'>
            <LoadingIndicator />
          </div>
        </div>
      );
    } else if (isLoading || childrenCount > 0 || !emptyMessage) {
      scrollableArea = (
        <div className={classNames('scrollable', { fullscreen })} ref={this.setRef} onMouseMove={this.handleMouseMove}>
          <div role='feed' className='item-list'>
            {prepend}

            {React.Children.map(this.props.children, (child, index) => (
              <IntersectionObserverArticleContainer
                key={child.key}
                id={child.key}
                index={index}
                listLength={childrenCount}
                intersectionObserverWrapper={this.intersectionObserverWrapper}
                saveHeightKey={trackScroll ? `${this.context.router.route.location.key}:${scrollKey}` : null}
              >
                {child}
              </IntersectionObserverArticleContainer>
            ))}

            {loadMore}
          </div>
        </div>
      );
    } else {
      const scrollable = alwaysShowScrollbar;

      scrollableArea = (
        <div className={classNames({ scrollable, fullscreen })} ref={this.setRef} style={{ flex: '1 1 auto', display: 'flex', flexDirection: 'column' }}>
          {alwaysPrepend && prepend}

          <div className='empty-column-indicator'>
            {emptyMessage}
          </div>
        </div>
      );
    }

    if (trackScroll) {
      return (
        <ScrollContainer scrollKey={scrollKey} shouldUpdateScroll={shouldUpdateScroll}>
          {scrollableArea}
        </ScrollContainer>
      );
    } else {
      return scrollableArea;
    }
  }

}

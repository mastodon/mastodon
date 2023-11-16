import { Children, cloneElement, PureComponent } from 'react';

import classNames from 'classnames';
import { useLocation } from 'react-router-dom';

import { List as ImmutableList } from 'immutable';
import { connect } from 'react-redux';

import { supportsPassiveEvents } from 'detect-passive-events';
import { throttle } from 'lodash';

import { ScrollContainer } from 'mastodon/containers/scroll_container';
import type { RootState } from 'mastodon/store';

import IntersectionObserverArticleContainer from '../containers/intersection_observer_article_container';
import {
  attachFullscreenListener,
  detachFullscreenListener,
  isFullscreen,
} from '../features/ui/util/fullscreen';
import IntersectionObserverWrapper from '../features/ui/util/intersection_observer_wrapper';

import { LoadMore } from './load_more';
import { LoadPending } from './load_pending';
import { LoadingIndicator } from './loading_indicator';

const MOUSE_IDLE_DELAY = 300;

const listenerOptions: AddEventListenerOptions | boolean = supportsPassiveEvents
  ? { passive: true }
  : false;

interface PropsForState {
  scrollKey: string;
}

const mapStateToProps = (state: RootState, { scrollKey }: PropsForState) => {
  return {
    preventScroll: scrollKey === state.dropdownMenu.scrollKey,
  };
};

interface IOArticleContainerWrapperProps {
  children?: React.ReactNode;
  id?: number | string | null;
  index?: number | string;
  intersectionObserverWrapper: unknown;
  listLength?: number | string;
  scrollKey: string;
  trackScroll?: boolean;
}

// This component only exists to be able to call useLocation()
const IOArticleContainerWrapper = ({
  id,
  index,
  listLength,
  intersectionObserverWrapper,
  trackScroll,
  scrollKey,
  children,
}: IOArticleContainerWrapperProps) => {
  const location = useLocation();

  return (
    <IntersectionObserverArticleContainer
      id={id}
      index={index}
      listLength={listLength}
      intersectionObserverWrapper={intersectionObserverWrapper}
      saveHeightKey={trackScroll ? `${location.key}:${scrollKey}` : null}
    >
      {children}
    </IntersectionObserverArticleContainer>
  );
};

interface ScrollableListProps {
  alwaysPrepend?: boolean;
  append?: React.ReactNode;
  bindToDocument?: boolean;
  children?: ImmutableList<React.ReactElement> | React.ReactElement;
  emptyMessage?: React.ReactNode;
  hasMore?: boolean;
  isLoading?: boolean;
  numPending: number;
  onLoadMore?: () => void;
  onLoadPending?: () => void;
  onScroll?: () => void;
  onScrollToTop?: () => void;
  prepend?: React.ReactNode;
  preventScroll?: boolean;
  scrollKey: string;
  showLoading?: boolean;
  trackScroll?: boolean;
}

interface ScrollableListState {
  cachedMediaWidth: number;
  fullscreen: boolean | null;
}

class ScrollableListInternal extends PureComponent<ScrollableListProps> {
  static defaultProps = {
    trackScroll: true,
  };

  state: ScrollableListState = {
    fullscreen: null,
    cachedMediaWidth: 250, // Default media/card width using default Mastodon theme
  };

  intersectionObserverWrapper = new IntersectionObserverWrapper();

  node: Element | undefined;

  handleScroll = throttle(
    () => {
      if (this.node) {
        const scrollTop = this.getScrollTop();
        const scrollHeight = this.getScrollHeight();
        const clientHeight = this.getClientHeight();
        const offset = scrollHeight - scrollTop - clientHeight;

        if (
          scrollTop > 0 &&
          offset < 400 &&
          this.props.onLoadMore &&
          this.props.hasMore &&
          !this.props.isLoading
        ) {
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
    },
    150,
    {
      trailing: true,
    },
  );

  mouseIdleTimer: ReturnType<typeof setTimeout> | null = null;
  mouseMovedRecently = false;
  lastScrollWasSynthetic = false;
  scrollToTopOnMouseIdle = false;

  _getScrollingElement = () => {
    if (this.props.bindToDocument) {
      return document.scrollingElement ?? document.body;
    } else {
      return this.node;
    }
  };

  setScrollTop = (newScrollTop: number) => {
    if (this.getScrollTop() !== newScrollTop) {
      this.lastScrollWasSynthetic = true;

      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      this._getScrollingElement()!.scrollTop = newScrollTop;
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

    if (!this.mouseMovedRecently && this.getScrollTop() === 0) {
      // Only set if we just started moving and are scrolled to the top.
      this.scrollToTopOnMouseIdle = true;
    }

    // Save setting this flag for last, so we can do the comparison above.
    this.mouseMovedRecently = true;
  }, MOUSE_IDLE_DELAY / 2);

  handleWheel = throttle(
    () => {
      this.scrollToTopOnMouseIdle = false;
    },
    150,
    {
      trailing: true,
    },
  );

  handleMouseIdle = () => {
    if (this.scrollToTopOnMouseIdle && !this.props.preventScroll) {
      this.setScrollTop(0);
    }

    this.mouseMovedRecently = false;
    this.scrollToTopOnMouseIdle = false;
  };

  componentDidMount() {
    this.attachScrollListener();
    this.attachIntersectionObserver();

    attachFullscreenListener(this.onFullScreenChange);

    // Handle initial scroll position
    this.handleScroll();
  }

  getScrollPosition = () => {
    if (this.node && (this.getScrollTop() > 0 || this.mouseMovedRecently)) {
      return { height: this.getScrollHeight(), top: this.getScrollTop() };
    } else {
      return null;
    }
  };

  getScrollTop = () => {
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    return this._getScrollingElement()!.scrollTop;
  };

  getScrollHeight = () => {
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    return this._getScrollingElement()!.scrollHeight;
  };

  getClientHeight = () => {
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    return this._getScrollingElement()!.clientHeight;
  };

  updateScrollBottom = (snapshot: number) => {
    const newScrollTop = this.getScrollHeight() - snapshot;

    this.setScrollTop(newScrollTop);
  };

  getSnapshotBeforeUpdate(prevProps: ScrollableListProps) {
    const someItemInserted =
      Children.count(prevProps.children) > 0 &&
      Children.count(prevProps.children) <
        Children.count(this.props.children) &&
      this.getFirstChildKey(prevProps) !== this.getFirstChildKey(this.props);
    const pendingChanged =
      prevProps.numPending > 0 !== this.props.numPending > 0;

    if (
      pendingChanged ||
      (someItemInserted &&
        (this.getScrollTop() > 0 ||
          this.mouseMovedRecently ||
          this.props.preventScroll))
    ) {
      return this.getScrollHeight() - this.getScrollTop();
    } else {
      return null;
    }
  }

  componentDidUpdate(
    prevProps: ScrollableListProps,
    prevState: ScrollableListState,
    snapshot: number | null,
  ) {
    // Reset the scroll position when a new child comes in in order not to
    // jerk the scrollbar around if you're already scrolled down the page.
    if (snapshot !== null) {
      this.setScrollTop(this.getScrollHeight() - snapshot);
    }
  }

  cacheMediaWidth = (width: number) => {
    if (width && this.state.cachedMediaWidth !== width) {
      this.setState({ cachedMediaWidth: width });
    }
  };

  componentWillUnmount() {
    this.clearMouseIdleTimer();
    this.detachScrollListener();
    this.detachIntersectionObserver();

    detachFullscreenListener(this.onFullScreenChange);
  }

  onFullScreenChange = () => {
    this.setState({ fullscreen: isFullscreen() });
  };

  attachIntersectionObserver() {
    const nodeOptions = {
      root: this.node,
      rootMargin: '300% 0px',
    };

    this.intersectionObserverWrapper.connect(
      this.props.bindToDocument ? {} : nodeOptions,
    );
  }

  detachIntersectionObserver() {
    this.intersectionObserverWrapper.disconnect();
  }

  /* eslint-disable @typescript-eslint/no-non-null-assertion */

  attachScrollListener() {
    if (this.props.bindToDocument) {
      document.addEventListener('scroll', this.handleScroll);
      document.addEventListener('wheel', this.handleWheel, listenerOptions);
    } else {
      this.node!.addEventListener('scroll', this.handleScroll);
      this.node!.addEventListener('wheel', this.handleWheel, listenerOptions);
    }
  }

  detachScrollListener() {
    if (this.props.bindToDocument) {
      document.removeEventListener('scroll', this.handleScroll);
      document.removeEventListener('wheel', this.handleWheel, listenerOptions);
    } else {
      this.node!.removeEventListener('scroll', this.handleScroll);
      this.node!.removeEventListener(
        'wheel',
        this.handleWheel,
        listenerOptions,
      );
    }
  }

  /* eslint-enable @typescript-eslint/no-non-null-assertion */

  getFirstChildKey(props: ScrollableListProps) {
    const { children } = props;
    let firstChild = children as React.ReactElement | undefined;

    if (children instanceof ImmutableList) {
      firstChild = (children as ImmutableList<React.ReactElement>).get(0);
    } else if (Array.isArray(children)) {
      firstChild = (children as React.ReactElement[])[0];
    }

    return firstChild?.key;
  }

  setRef = (c: HTMLDivElement) => {
    this.node = c;
  };

  handleLoadMore = (e: React.MouseEvent) => {
    e.preventDefault();
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    this.props.onLoadMore!();
  };

  handleLoadPending = (e: React.MouseEvent) => {
    e.preventDefault();
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    this.props.onLoadPending!();
    // Prevent the weird scroll-jumping behavior, as we explicitly don't want to
    // scroll to top, and we know the scroll height is going to change
    this.scrollToTopOnMouseIdle = false;
    this.lastScrollWasSynthetic = false;
    this.clearMouseIdleTimer();
    this.mouseIdleTimer = setTimeout(this.handleMouseIdle, MOUSE_IDLE_DELAY);
    this.mouseMovedRecently = true;
  };

  render() {
    const {
      children,
      scrollKey,
      trackScroll,
      showLoading,
      isLoading,
      hasMore,
      numPending,
      prepend,
      alwaysPrepend,
      append,
      emptyMessage,
      onLoadMore,
    } = this.props;
    const { fullscreen } = this.state;
    const childrenCount = Children.count(children);

    const loadMore =
      hasMore && onLoadMore ? (
        <LoadMore visible={!isLoading} onClick={this.handleLoadMore} />
      ) : null;
    const loadPending =
      numPending > 0 ? (
        <LoadPending count={numPending} onClick={this.handleLoadPending} />
      ) : null;
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
    } else if (
      isLoading ||
      childrenCount > 0 ||
      numPending > 0 ||
      hasMore ||
      !emptyMessage
    ) {
      scrollableArea = (
        <div
          className={classNames('scrollable', { fullscreen })}
          ref={this.setRef}
          onMouseMove={this.handleMouseMove}
        >
          <div role='feed' className='item-list'>
            {prepend}

            {loadPending}

            {Children.map(
              this.props.children as unknown as readonly React.ReactElement[],
              (child, index) => (
                <IOArticleContainerWrapper
                  key={child.key}
                  id={child.key}
                  index={index}
                  listLength={childrenCount}
                  intersectionObserverWrapper={this.intersectionObserverWrapper}
                  trackScroll={trackScroll}
                  scrollKey={scrollKey}
                >
                  {cloneElement(child, {
                    getScrollPosition: this.getScrollPosition,
                    updateScrollBottom: this.updateScrollBottom,
                    cachedMediaWidth: this.state.cachedMediaWidth,
                    cacheMediaWidth: this.cacheMediaWidth,
                  })}
                </IOArticleContainerWrapper>
              ),
            )}

            {loadMore}

            {!hasMore && append}
          </div>
        </div>
      );
    } else {
      scrollableArea = (
        <div
          className={classNames('scrollable scrollable--flex', { fullscreen })}
          ref={this.setRef}
        >
          {alwaysPrepend && prepend}

          <div className='empty-column-indicator'>{emptyMessage}</div>
        </div>
      );
    }

    if (trackScroll) {
      return (
        <ScrollContainer scrollKey={scrollKey}>
          {scrollableArea}
        </ScrollContainer>
      );
    } else {
      return scrollableArea;
    }
  }
}

export const ScrollableList = connect(mapStateToProps, null, null, {
  forwardRef: true,
})(ScrollableListInternal);

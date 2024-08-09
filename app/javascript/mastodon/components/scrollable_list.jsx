import PropTypes from 'prop-types';
import { Children, cloneElement, PureComponent } from 'react';

import classNames from 'classnames';
import { useLocation } from 'react-router-dom';

import { List as ImmutableList } from 'immutable';
import { connect } from 'react-redux';

import { throttle } from 'lodash';

import ScrollContainer from 'mastodon/containers/scroll_container';

import IntersectionObserverArticleContainer from '../containers/intersection_observer_article_container';
import { attachFullscreenListener, detachFullscreenListener, isFullscreen } from '../features/ui/util/fullscreen';
import IntersectionObserverWrapper from '../features/ui/util/intersection_observer_wrapper';

import { LoadMore } from './load_more';
import { LoadPending } from './load_pending';
import { LoadingIndicator } from './loading_indicator';

/**
 *
 * @param {import('mastodon/store').RootState} state
 * @param {*} props
 */
const mapStateToProps = (state, { scrollKey }) => {
  return {
    preventScroll: scrollKey === state.dropdownMenu.scrollKey,
  };
};

// This component only exists to be able to call useLocation()
const IOArticleContainerWrapper = ({id, index, listLength, intersectionObserverWrapper, trackScroll, scrollKey, children}) => {
  const location = useLocation();

  return (<IntersectionObserverArticleContainer
    id={id}
    index={index}
    listLength={listLength}
    intersectionObserverWrapper={intersectionObserverWrapper}
    saveHeightKey={trackScroll ? `${location.key}:${scrollKey}` : null}
  >
    {children}
  </IntersectionObserverArticleContainer>);
};

IOArticleContainerWrapper.propTypes =  {
  id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  index: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  listLength: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  scrollKey: PropTypes.string.isRequired,
  intersectionObserverWrapper: PropTypes.object.isRequired,
  trackScroll: PropTypes.bool.isRequired,
  children: PropTypes.node,
};

class ScrollableList extends PureComponent {

  static propTypes = {
    scrollKey: PropTypes.string.isRequired,
    onLoadMore: PropTypes.func,
    onLoadPending: PropTypes.func,
    onScrollToTop: PropTypes.func,
    onScroll: PropTypes.func,
    trackScroll: PropTypes.bool,
    isLoading: PropTypes.bool,
    showLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    numPending: PropTypes.number,
    prepend: PropTypes.node,
    append: PropTypes.node,
    alwaysPrepend: PropTypes.bool,
    emptyMessage: PropTypes.node,
    children: PropTypes.node,
    bindToDocument: PropTypes.bool,
    preventScroll: PropTypes.bool,
  };

  static defaultProps = {
    trackScroll: true,
  };

  state = {
    fullscreen: null,
    cachedMediaWidth: 250, // Default media/card width using default Mastodon theme
  };

  intersectionObserverWrapper = new IntersectionObserverWrapper();
  articleOfInterest = null;
  scrollAdjustment = 0;

  handleScroll = throttle(() => {
    if (this.node) {
      const scrollTop = this.getScrollTop();
      const scrollHeight = this.getScrollHeight();
      const clientHeight = this.getClientHeight();
      const offset = scrollHeight - scrollTop - clientHeight;

      if (scrollTop > 0 && offset < 400 && this.props.onLoadMore && this.props.hasMore && !this.props.isLoading) {
        this.props.onLoadMore();
      }

      if (scrollTop < 100 && this.props.onScrollToTop) {
        this.props.onScrollToTop();
      } else if (this.props.onScroll) {
        this.props.onScroll();
      }
    }
  }, 150, {
    trailing: true,
  });

  _getScrollingElement = () => {
    if (this.props.bindToDocument) {
      return (document.scrollingElement || document.body);
    } else {
      return this.node;
    }
  };

  setScrollTop = newScrollTop => {
    if (this.getScrollTop() !== newScrollTop) {
      this._getScrollingElement().scrollTop = newScrollTop;
    }
  };

  componentDidMount () {
    this.attachScrollListener();
    this.attachIntersectionObserver();

    attachFullscreenListener(this.onFullScreenChange);

    // Handle initial scroll position
    this.handleScroll();

    // If we are bound to the document, the stuff above the scrollable has to
    // be taken into account when we focus back to the article we want.
    if (this.props.bindToDocument) {
      this.scrollAdjustment = this.node.getBoundingClientRect().top;
    }
  }

  getScrollPosition = () => {
    if (this.node && this.getScrollTop() > 0) {
      return { height: this.getScrollHeight(), top: this.getScrollTop() };
    } else {
      return null;
    }
  };

  getScrollTop = () => {
    return this._getScrollingElement().scrollTop;
  };

  getScrollHeight = () => {
    return this._getScrollingElement().scrollHeight;
  };

  getClientHeight = () => {
    return this._getScrollingElement().clientHeight;
  };

  updateScrollBottom = (snapshot) => {
    const newScrollTop = this.getScrollHeight() - snapshot;

    this.setScrollTop(newScrollTop);
  };

  cacheMediaWidth = (width) => {
    if (width && this.state.cachedMediaWidth !== width) {
      this.setState({ cachedMediaWidth: width });
    }
  };

  componentWillUnmount () {
    this.detachScrollListener();
    this.detachIntersectionObserver();

    detachFullscreenListener(this.onFullScreenChange);
  }

  onFullScreenChange = () => {
    this.setState({ fullscreen: isFullscreen() });
  };

  attachIntersectionObserver () {
    let nodeOptions = {
      root: this.node,
      rootMargin: '300% 0px',
    };

    this.intersectionObserverWrapper
      .connect(this.props.bindToDocument ? {} : nodeOptions);
  }

  detachIntersectionObserver () {
    this.intersectionObserverWrapper.disconnect();
  }

  attachScrollListener () {
    if (this.props.bindToDocument) {
      document.addEventListener('scroll', this.handleScroll);
    } else {
      this.node.addEventListener('scroll', this.handleScroll);
    }
  }

  detachScrollListener () {
    if (this.props.bindToDocument) {
      document.removeEventListener('scroll', this.handleScroll);
    } else {
      this.node.removeEventListener('scroll', this.handleScroll);
    }
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
  };

  preLoad = () => {
    // Here we record the article of interest so that when we mouseUp on
    // the LoadX element, were able to scroll back to it.

    // Note that it does not matter whether we are binding to the document, or
    // not. The node we have to test is always that of the scrollable itself.
    const scrollableRect = this.node.getBoundingClientRect();
    const articles = this.node.querySelectorAll("article");
    for (const article of articles) {
      const articleRect = article.getBoundingClientRect();
      if (articleRect.top >= scrollableRect.top) {
        this.articleOfInterest = article;
        break;
      }
    }
  }

  returnToArticleOfInterest () {
    let article = this.articleOfInterest;
    if (article === null) {
      return;
    }

    // Scroll the articleOfInterest back into view once we're done with
    // everything else.
    setTimeout(() => {
      // We try to find the article previous to the article of interest in the
      // list of articles. That's the article we finally want to focus on.
      let prev = article.previousElementSibling;
      while (prev !== null) {
        if (prev.localName === "article") {
          article = prev;
          break;
        }

        prev = prev.previousElementSibling;
      }


      // We need to adjust with the scrollAdjustment. It is non-zero only when
      // we bind to the document.
      this.setScrollTop(this.getScrollTop() +
                        article.getBoundingClientRect().top -
                        this.scrollAdjustment);
      article.querySelector("div.status__wrapper").focus();
    }, 0);
  }


  handleLoadMore = e => {
    e.preventDefault();
    this.props.onLoadMore();
    this.returnToArticleOfInterest();
  };

  handleLoadPending = e => {
    e.preventDefault();
    this.props.onLoadPending();
    this.returnToArticleOfInterest();
  };

  render () {
    const { children, scrollKey, trackScroll, showLoading, isLoading, hasMore, numPending, prepend, alwaysPrepend, append, emptyMessage, onLoadMore } = this.props;
    const { fullscreen } = this.state;
    const childrenCount = Children.count(children);

    const loadMore     = (hasMore && onLoadMore) ? <LoadMore visible={!isLoading} onMouseDown={this.preLoad} onMouseUp={this.handleLoadMore} /> : null;
    const loadPending  = (numPending > 0) ? <LoadPending count={numPending} onMouseDown={this.preLoad} onMouseUp={this.handleLoadPending} /> : null;
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
    } else if (isLoading || childrenCount > 0 || numPending > 0 || hasMore || !emptyMessage) {
      scrollableArea = (
        <div className={classNames('scrollable', { fullscreen })} ref={this.setRef}>
          <div role='feed' className='item-list'>
            {prepend}

            {loadPending}

            {Children.map(this.props.children, (child, index) => (
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
            ))}

            {loadMore}

            {!hasMore && append}
          </div>
        </div>
      );
    } else {
      scrollableArea = (
        <div className={classNames('scrollable scrollable--flex', { fullscreen })} ref={this.setRef}>
          {alwaysPrepend && prepend}

          <div className='empty-column-indicator'>
            {emptyMessage}
          </div>
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

export default connect(mapStateToProps, null, null, { forwardRef: true })(ScrollableList);

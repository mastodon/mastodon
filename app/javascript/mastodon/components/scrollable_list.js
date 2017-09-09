import React, { PureComponent } from 'react';
import { ScrollContainer } from 'react-router-scroll';
import PropTypes from 'prop-types';
import IntersectionObserverArticle from './intersection_observer_article';
import LoadMore from './load_more';
import IntersectionObserverWrapper from '../features/ui/util/intersection_observer_wrapper';
import { throttle } from 'lodash';

export default class ScrollableList extends PureComponent {

  static propTypes = {
    scrollKey: PropTypes.string.isRequired,
    onScrollToBottom: PropTypes.func,
    onScrollToTop: PropTypes.func,
    onScroll: PropTypes.func,
    trackScroll: PropTypes.bool,
    shouldUpdateScroll: PropTypes.func,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    prepend: PropTypes.node,
    emptyMessage: PropTypes.node,
    children: PropTypes.node,
  };

  static defaultProps = {
    trackScroll: true,
  };

  intersectionObserverWrapper = new IntersectionObserverWrapper();

  handleScroll = throttle(() => {
    if (this.node) {
      const { scrollTop, scrollHeight, clientHeight } = this.node;
      const offset = scrollHeight - scrollTop - clientHeight;
      this._oldScrollPosition = scrollHeight - scrollTop;

      if (400 > offset && this.props.onScrollToBottom && !this.props.isLoading) {
        this.props.onScrollToBottom();
      } else if (scrollTop < 100 && this.props.onScrollToTop) {
        this.props.onScrollToTop();
      } else if (this.props.onScroll) {
        this.props.onScroll();
      }
    }
  }, 150, {
    trailing: true,
  });

  componentDidMount () {
    this.attachScrollListener();
    this.attachIntersectionObserver();

    // Handle initial scroll posiiton
    this.handleScroll();
  }

  componentDidUpdate (prevProps) {
    // Reset the scroll position when a new child comes in in order not to
    // jerk the scrollbar around if you're already scrolled down the page.
    if (React.Children.count(prevProps.children) < React.Children.count(this.props.children) && this._oldScrollPosition && this.node.scrollTop > 0) {
      if (this.getFirstChildKey(prevProps) !== this.getFirstChildKey(this.props)) {
        const newScrollTop = this.node.scrollHeight - this._oldScrollPosition;
        if (this.node.scrollTop !== newScrollTop) {
          this.node.scrollTop = newScrollTop;
        }
      } else {
        this._oldScrollPosition = this.node.scrollHeight - this.node.scrollTop;
      }
    }
  }

  componentWillUnmount () {
    this.detachScrollListener();
    this.detachIntersectionObserver();
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
  }

  detachScrollListener () {
    this.node.removeEventListener('scroll', this.handleScroll);
  }

  getFirstChildKey (props) {
    const { children } = props;
    const firstChild = Array.isArray(children) ? children[0] : children;
    return firstChild && firstChild.key;
  }

  setRef = (c) => {
    this.node = c;
  }

  handleLoadMore = (e) => {
    e.preventDefault();
    this.props.onScrollToBottom();
  }

  handleKeyDown = (e) => {
    if (['PageDown', 'PageUp'].includes(e.key) || (e.ctrlKey && ['End', 'Home'].includes(e.key))) {
      const article = (() => {
        switch (e.key) {
        case 'PageDown':
          return e.target.nodeName === 'ARTICLE' && e.target.nextElementSibling;
        case 'PageUp':
          return e.target.nodeName === 'ARTICLE' && e.target.previousElementSibling;
        case 'End':
          return this.node.querySelector('[role="feed"] > article:last-of-type');
        case 'Home':
          return this.node.querySelector('[role="feed"] > article:first-of-type');
        default:
          return null;
        }
      })();


      if (article) {
        e.preventDefault();
        article.focus();
        article.scrollIntoView();
      }
    }
  }

  render () {
    const { children, scrollKey, trackScroll, shouldUpdateScroll, isLoading, hasMore, prepend, emptyMessage } = this.props;
    const childrenCount = React.Children.count(children);

    const loadMore     = <LoadMore visible={!isLoading && childrenCount > 0 && hasMore} onClick={this.handleLoadMore} />;
    let scrollableArea = null;

    if (isLoading || childrenCount > 0 || !emptyMessage) {
      scrollableArea = (
        <div className='scrollable' ref={this.setRef}>
          <div role='feed' className='item-list' onKeyDown={this.handleKeyDown}>
            {prepend}

            {React.Children.map(this.props.children, (child, index) => (
              <IntersectionObserverArticle key={child.key} id={child.key} index={index} listLength={childrenCount} intersectionObserverWrapper={this.intersectionObserverWrapper}>
                {child}
              </IntersectionObserverArticle>
            ))}

            {loadMore}
          </div>
        </div>
      );
    } else {
      scrollableArea = (
        <div className='empty-column-indicator' ref={this.setRef}>
          {emptyMessage}
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

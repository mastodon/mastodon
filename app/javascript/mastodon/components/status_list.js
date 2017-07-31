import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { ScrollContainer } from 'react-router-scroll';
import PropTypes from 'prop-types';
import StatusContainer from '../containers/status_container';
import LoadMore from './load_more';
import ImmutablePureComponent from 'react-immutable-pure-component';
import IntersectionObserverWrapper from '../features/ui/util/intersection_observer_wrapper';
import { throttle } from 'lodash';

export default class StatusList extends ImmutablePureComponent {

  static propTypes = {
    scrollKey: PropTypes.string.isRequired,
    statusIds: ImmutablePropTypes.list.isRequired,
    onScrollToBottom: PropTypes.func,
    onScrollToTop: PropTypes.func,
    onScroll: PropTypes.func,
    trackScroll: PropTypes.bool,
    shouldUpdateScroll: PropTypes.func,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    prepend: PropTypes.node,
    emptyMessage: PropTypes.node,
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
    // Reset the scroll position when a new toot comes in in order not to
    // jerk the scrollbar around if you're already scrolled down the page.
    if (prevProps.statusIds.size < this.props.statusIds.size && this._oldScrollPosition && this.node.scrollTop > 0) {
      if (prevProps.statusIds.first() !== this.props.statusIds.first()) {
        let newScrollTop = this.node.scrollHeight - this._oldScrollPosition;
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

  setRef = (c) => {
    this.node = c;
  }

  handleLoadMore = (e) => {
    e.preventDefault();
    this.props.onScrollToBottom();
  }

  handleKeyDown = (e) => {
    if (['PageDown', 'PageUp', 'End', 'Home'].includes(e.key)) {
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
    const { statusIds, scrollKey, trackScroll, shouldUpdateScroll, isLoading, hasMore, prepend, emptyMessage } = this.props;

    const loadMore     = <LoadMore visible={!isLoading && statusIds.size > 0 && hasMore} onClick={this.handleLoadMore} />;
    let scrollableArea = null;

    if (isLoading || statusIds.size > 0 || !emptyMessage) {
      scrollableArea = (
        <div className='scrollable' ref={this.setRef}>
          <div role='feed' className='status-list' onKeyDown={this.handleKeyDown}>
            {prepend}

            {statusIds.map((statusId, index) => {
              return <StatusContainer key={statusId} id={statusId} index={index} listLength={statusIds.size} intersectionObserverWrapper={this.intersectionObserverWrapper} />;
            })}

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

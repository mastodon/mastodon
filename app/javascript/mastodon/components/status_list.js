import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { ScrollContainer } from 'react-router-scroll';
import PropTypes from 'prop-types';
import StatusContainer from '../containers/status_container';
import LoadMore from './load_more';
import ImmutablePureComponent from 'react-immutable-pure-component';

class StatusList extends ImmutablePureComponent {

  static propTypes = {
    scrollKey: PropTypes.string.isRequired,
    statusIds: ImmutablePropTypes.list.isRequired,
    onScrollToBottom: PropTypes.func,
    onScrollToTop: PropTypes.func,
    onScroll: PropTypes.func,
    shouldUpdateScroll: PropTypes.func,
    isLoading: PropTypes.bool,
    isUnread: PropTypes.bool,
    hasMore: PropTypes.bool,
    prepend: PropTypes.node,
    emptyMessage: PropTypes.node,
  };

  static defaultProps = {
    trackScroll: true,
  };

  state = {
    isIntersecting: {},
    intersectionCount: 0,
  }

  statusRefQueue = []

  handleScroll = (e) => {
    const { scrollTop, scrollHeight, clientHeight } = e.target;
    const offset = scrollHeight - scrollTop - clientHeight;
    this._oldScrollPosition = scrollHeight - scrollTop;

    if (250 > offset && this.props.onScrollToBottom && !this.props.isLoading) {
      this.props.onScrollToBottom();
    } else if (scrollTop < 100 && this.props.onScrollToTop) {
      this.props.onScrollToTop();
    } else if (this.props.onScroll) {
      this.props.onScroll();
    }
  }

  componentDidMount () {
    this.attachScrollListener();
    this.attachIntersectionObserver();
  }

  componentDidUpdate (prevProps) {
    if ((prevProps.statusIds.size < this.props.statusIds.size && prevProps.statusIds.first() !== this.props.statusIds.first() && !!this._oldScrollPosition) && this.node.scrollTop > 0) {
      this.node.scrollTop = this.node.scrollHeight - this._oldScrollPosition;
    }
  }

  componentWillUnmount () {
    this.detachScrollListener();
    this.detachIntersectionObserver();
  }

  attachIntersectionObserver () {
    const onIntersection = (entries) => {
      this.setState(state => {

        entries.forEach(entry => {
          const statusId = entry.target.getAttribute('data-id');

          // Edge 15 doesn't support isIntersecting, but we can infer it from intersectionRatio
          // https://developer.microsoft.com/en-us/microsoft-edge/platform/issues/12156111/
          state.isIntersecting[statusId] = entry.intersectionRatio > 0;
        });

        // isIntersecting is a map of DOM data-id's to booleans (true for
        // intersecting, false for non-intersecting).
        //
        // We always want to return true in shouldComponentUpdate() if
        // this object changes, because onIntersection() is only called if
        // something has changed.
        //
        // Now, we *could* use an immutable map or some other structure to
        // diff the full map, but that would be pointless because the browser
        // has already informed us that something has changed. So we can just
        // use a regular object, which will be diffed by ImmutablePureComponent
        // based on reference equality (i.e. it's always "unchanged") and
        // then we just increment intersectionCount to force a change.

        return {
          isIntersecting: state.isIntersecting,
          intersectionCount: state.intersectionCount + 1,
        };
      });
    };

    const options = {
      root: this.node,
      rootMargin: '300% 0px',
    };

    this.intersectionObserver = new IntersectionObserver(onIntersection, options);

    if (this.statusRefQueue.length) {
      this.statusRefQueue.forEach(node => this.intersectionObserver.observe(node));
      this.statusRefQueue = [];
    }
  }

  detachIntersectionObserver () {
    this.intersectionObserver.disconnect();
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

  handleStatusRef = (node) => {
    if (node && this.intersectionObserver) {
      const statusId = node.getAttribute('data-id');
      this.intersectionObserver.observe(node);
    } else {
      this.statusRefQueue.push(node);
    }
  }

  handleLoadMore = (e) => {
    e.preventDefault();
    this.props.onScrollToBottom();
  }

  render () {
    const { statusIds, onScrollToBottom, scrollKey, shouldUpdateScroll, isLoading, isUnread, hasMore, prepend, emptyMessage } = this.props;
    const { isIntersecting } = this.state;

    let loadMore       = null;
    let scrollableArea = null;
    let unread         = null;

    if (!isLoading && statusIds.size > 0 && hasMore) {
      loadMore = <LoadMore onClick={this.handleLoadMore} />;
    }

    if (isUnread) {
      unread = <div className='status-list__unread-indicator' />;
    }

    if (isLoading || statusIds.size > 0 || !emptyMessage) {
      scrollableArea = (
        <div className='scrollable' ref={this.setRef}>
          {unread}

          <div className='status-list'>
            {prepend}

            {statusIds.map((statusId) => {
              return <StatusContainer key={statusId} id={statusId} isIntersecting={isIntersecting[statusId]} onRef={this.handleStatusRef} />;
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

    return (
      <ScrollContainer scrollKey={scrollKey} shouldUpdateScroll={shouldUpdateScroll}>
        {scrollableArea}
      </ScrollContainer>
    );
  }

}

export default StatusList;

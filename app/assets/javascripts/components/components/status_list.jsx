import Status from './status';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { ScrollContainer } from 'react-router-scroll';
import PropTypes from 'prop-types';
import StatusContainer from '../containers/status_container';
import LoadMore from './load_more';

class StatusList extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.handleScroll = this.handleScroll.bind(this);
    this.setRef = this.setRef.bind(this);
    this.handleLoadMore = this.handleLoadMore.bind(this);
  }

  handleScroll (e) {
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
  }

  componentDidUpdate (prevProps) {
    if (this.node.scrollTop > 0 && (prevProps.statusIds.size < this.props.statusIds.size && prevProps.statusIds.first() !== this.props.statusIds.first() && !!this._oldScrollPosition)) {
      this.node.scrollTop = this.node.scrollHeight - this._oldScrollPosition;
    }
  }

  componentWillUnmount () {
    this.detachScrollListener();
  }

  attachScrollListener () {
    this.node.addEventListener('scroll', this.handleScroll);
  }

  detachScrollListener () {
    this.node.removeEventListener('scroll', this.handleScroll);
  }

  setRef (c) {
    this.node = c;
  }

  handleLoadMore (e) {
    e.preventDefault();
    this.props.onScrollToBottom();
  }

  render () {
    const { statusIds, onScrollToBottom, trackScroll, isLoading, isUnread, hasMore, prepend, emptyMessage } = this.props;

    let loadMore       = '';
    let scrollableArea = '';
    let unread         = '';

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
              return <StatusContainer key={statusId} id={statusId} />;
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
        <ScrollContainer scrollKey='status-list'>
          {scrollableArea}
        </ScrollContainer>
      );
    } else {
      return scrollableArea;
    }
  }

}

StatusList.propTypes = {
  statusIds: ImmutablePropTypes.list.isRequired,
  onScrollToBottom: PropTypes.func,
  onScrollToTop: PropTypes.func,
  onScroll: PropTypes.func,
  trackScroll: PropTypes.bool,
  isLoading: PropTypes.bool,
  isUnread: PropTypes.bool,
  hasMore: PropTypes.bool,
  prepend: PropTypes.node,
  emptyMessage: PropTypes.node
};

StatusList.defaultProps = {
  trackScroll: true
};

export default StatusList;

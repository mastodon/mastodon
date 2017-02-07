import Status from './status';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import { ScrollContainer } from 'react-router-scroll';
import StatusContainer from '../containers/status_container';
import LoadMore from './load_more';

const StatusList = React.createClass({

  propTypes: {
    statusIds: ImmutablePropTypes.list.isRequired,
    onScrollToBottom: React.PropTypes.func,
    onScrollToTop: React.PropTypes.func,
    onScroll: React.PropTypes.func,
    trackScroll: React.PropTypes.bool,
    isLoading: React.PropTypes.bool,
    prepend: React.PropTypes.node
  },

  getDefaultProps () {
    return {
      trackScroll: true
    };
  },

  mixins: [PureRenderMixin],

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
  },

  componentDidMount () {
    this.attachScrollListener();
  },

  componentDidUpdate (prevProps) {
    if (this.node.scrollTop > 0 && (prevProps.statusIds.size < this.props.statusIds.size && prevProps.statusIds.first() !== this.props.statusIds.first() && !!this._oldScrollPosition)) {
      this.node.scrollTop = this.node.scrollHeight - this._oldScrollPosition;
    }
  },

  componentWillUnmount () {
    this.detachScrollListener();
  },

  attachScrollListener () {
    this.node.addEventListener('scroll', this.handleScroll);
  },

  detachScrollListener () {
    this.node.removeEventListener('scroll', this.handleScroll);
  },

  setRef (c) {
    this.node = c;
  },

  handleLoadMore (e) {
    e.preventDefault();
    this.props.onScrollToBottom();
  },

  render () {
    const { statusIds, onScrollToBottom, trackScroll, isLoading, prepend } = this.props;

    let loadMore = '';

    if (!isLoading && statusIds.size > 0) {
      loadMore = <LoadMore onClick={this.handleLoadMore} />;
    }

    const scrollableArea = (
      <div className='scrollable' ref={this.setRef}>
        <div>
          {prepend}

          {statusIds.map((statusId) => {
            return <StatusContainer key={statusId} id={statusId} />;
          })}

          {loadMore}
        </div>
      </div>
    );

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

});

export default StatusList;

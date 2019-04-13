import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { expandHashtagTimeline } from '../../../actions/timelines';
import { connectHashtagStream } from '../../../actions/streaming';
import Masonry from 'react-masonry-infinite';
import { List as ImmutableList } from 'immutable';
import DetailedStatusContainer from '../../status/containers/detailed_status_container';
import { debounce } from 'lodash';
import LoadingIndicator from '../../../components/loading_indicator';

const mapStateToProps = (state, { hashtag }) => ({
  statusIds: state.getIn(['timelines', `hashtag:${hashtag}`, 'items'], ImmutableList()),
  isLoading: state.getIn(['timelines', `hashtag:${hashtag}`, 'isLoading'], false),
  hasMore: state.getIn(['timelines', `hashtag:${hashtag}`, 'hasMore'], false),
});

export default @connect(mapStateToProps)
class HashtagTimeline extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    statusIds: ImmutablePropTypes.list.isRequired,
    isLoading: PropTypes.bool.isRequired,
    hasMore: PropTypes.bool.isRequired,
    hashtag: PropTypes.string.isRequired,
  };

  componentDidMount () {
    const { dispatch, hashtag } = this.props;

    dispatch(expandHashtagTimeline(hashtag));
    this.disconnect = dispatch(connectHashtagStream(hashtag, hashtag));
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  handleLoadMore = () => {
    const maxId = this.props.statusIds.last();

    if (maxId) {
      this.props.dispatch(expandHashtagTimeline(this.props.hashtag, { maxId }));
    }
  }

  setRef = c => {
    this.masonry = c;
  }

  handleHeightChange = debounce(() => {
    if (!this.masonry) {
      return;
    }

    this.masonry.forcePack();
  }, 50)

  render () {
    const { statusIds, hasMore, isLoading } = this.props;

    const sizes = [
      { columns: 1, gutter: 0 },
      { mq: '415px', columns: 1, gutter: 10 },
      { mq: '640px', columns: 2, gutter: 10 },
      { mq: '960px', columns: 3, gutter: 10 },
      { mq: '1255px', columns: 3, gutter: 10 },
    ];

    const loader = (isLoading && statusIds.isEmpty()) ? <LoadingIndicator key={0} /> : undefined;

    return (
      <Masonry ref={this.setRef} className='statuses-grid' hasMore={hasMore} loadMore={this.handleLoadMore} sizes={sizes} loader={loader}>
        {statusIds.map(statusId => (
          <div className='statuses-grid__item' key={statusId}>
            <DetailedStatusContainer
              id={statusId}
              compact
              measureHeight
              onHeightChange={this.handleHeightChange}
            />
          </div>
        )).toArray()}
      </Masonry>
    );
  }

}

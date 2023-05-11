import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import StatusList from 'mastodon/components/status_list';
import { FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import { fetchBookmarkedStatuses, expandBookmarkedStatuses } from 'mastodon/actions/bookmarks';
import { debounce } from 'lodash';

const mapStateToProps = state => ({
  statusIds: state.getIn(['status_lists', 'bookmarks', 'items']),
  isLoading: state.getIn(['status_lists', 'bookmarks', 'isLoading'], true),
  hasMore: !!state.getIn(['status_lists', 'bookmarks', 'next']),
});

class Bookmarks extends React.PureComponent {

  static propTypes = {
    statusIds: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    multiColumn: PropTypes.bool,
    dispatch: PropTypes.func.isRequired,
  };

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(fetchBookmarkedStatuses());
  }

  handleLoadMore = debounce(() => {
    const { dispatch } = this.props;
    dispatch(expandBookmarkedStatuses());
  }, 300, { leading: true });

  render () {
    const { isLoading, hasMore, statusIds, multiColumn } = this.props;

    const emptyMessage = <FormattedMessage id='empty_column.bookmarked_statuses' defaultMessage="You don't have any bookmarked posts yet. When you bookmark one, it will show up here." />;

    return (
      <StatusList
        trackScroll
        statusIds={statusIds}
        scrollKey='bookmarked_statuses'
        hasMore={hasMore}
        isLoading={isLoading}
        onLoadMore={this.handleLoadMore}
        emptyMessage={emptyMessage}
        bindToDocument={!multiColumn}
      />
    );
  }

}

export default connect(mapStateToProps)(Bookmarks);

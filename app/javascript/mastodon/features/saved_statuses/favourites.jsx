import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import StatusList from 'mastodon/components/status_list';
import { FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import { fetchFavouritedStatuses, expandFavouritedStatuses } from 'mastodon/actions/favourites';
import { debounce } from 'lodash';

const mapStateToProps = state => ({
  statusIds: state.getIn(['status_lists', 'favourites', 'items']),
  isLoading: state.getIn(['status_lists', 'favourites', 'isLoading'], true),
  hasMore: !!state.getIn(['status_lists', 'favourites', 'next']),
});

class Favourites extends React.PureComponent {

  static propTypes = {
    statusIds: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    multiColumn: PropTypes.bool,
    dispatch: PropTypes.func.isRequired,
  };

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(fetchFavouritedStatuses());
  }

  handleLoadMore = debounce(() => {
    const { dispatch } = this.props;
    dispatch(expandFavouritedStatuses());
  }, 300, { leading: true });

  render () {
    const { isLoading, hasMore, statusIds, multiColumn } = this.props;

    const emptyMessage = <FormattedMessage id='empty_column.favourited_statuses' defaultMessage="You don't have any favourite posts yet. When you favourite one, it will show up here." />;

    return (
      <StatusList
        trackScroll
        statusIds={statusIds}
        scrollKey='favourited_statuses'
        hasMore={hasMore}
        isLoading={isLoading}
        onLoadMore={this.handleLoadMore}
        emptyMessage={emptyMessage}
        bindToDocument={!multiColumn}
      />
    );
  }

}

export default connect(mapStateToProps)(Favourites);

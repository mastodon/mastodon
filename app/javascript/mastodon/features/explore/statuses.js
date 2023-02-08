import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import StatusList from 'mastodon/components/status_list';
import { FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import { fetchTrendingStatuses, expandTrendingStatuses } from 'mastodon/actions/trends';
import { debounce } from 'lodash';
import DismissableBanner from 'mastodon/components/dismissable_banner';

const mapStateToProps = state => ({
  statusIds: state.getIn(['status_lists', 'trending', 'items']),
  isLoading: state.getIn(['status_lists', 'trending', 'isLoading'], true),
  hasMore: !!state.getIn(['status_lists', 'trending', 'next']),
});

export default @connect(mapStateToProps)
class Statuses extends React.PureComponent {

  static propTypes = {
    statusIds: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    multiColumn: PropTypes.bool,
    dispatch: PropTypes.func.isRequired,
  };

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(fetchTrendingStatuses());
  }

  handleLoadMore = debounce(() => {
    const { dispatch } = this.props;
    dispatch(expandTrendingStatuses());
  }, 300, { leading: true });

  render () {
    const { isLoading, hasMore, statusIds, multiColumn } = this.props;

    const emptyMessage = <FormattedMessage id='empty_column.explore_statuses' defaultMessage='Nothing is trending right now. Check back later!' />;

    return (
      <>
        <DismissableBanner id='explore/statuses'>
          <FormattedMessage id='dismissable_banner.explore_statuses' defaultMessage='These posts from this and other servers in the decentralized network are gaining traction on this server right now.' />
        </DismissableBanner>

        <StatusList
          trackScroll
          statusIds={statusIds}
          scrollKey='explore-statuses'
          hasMore={hasMore}
          isLoading={isLoading}
          onLoadMore={this.handleLoadMore}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
          withCounters
        />
      </>
    );
  }

}

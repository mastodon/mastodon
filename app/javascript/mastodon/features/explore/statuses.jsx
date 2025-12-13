import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import { withRouter } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import { debounce } from 'lodash';


import { fetchTrendingStatuses, expandTrendingStatuses } from 'mastodon/actions/trends';
import { DismissableBanner } from 'mastodon/components/dismissable_banner';
import StatusList from 'mastodon/components/status_list';
import { getStatusList } from 'mastodon/selectors';
import { WithRouterPropTypes } from 'mastodon/utils/react_router';

const mapStateToProps = state => ({
  statusIds: getStatusList(state, 'trending'),
  isLoading: state.getIn(['status_lists', 'trending', 'isLoading'], true),
  hasMore: !!state.getIn(['status_lists', 'trending', 'next']),
});

class Statuses extends PureComponent {

  static propTypes = {
    statusIds: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    multiColumn: PropTypes.bool,
    dispatch: PropTypes.func.isRequired,
    ...WithRouterPropTypes,
  };

  componentDidMount () {
    const { dispatch, statusIds, history } = this.props;

    // If we're navigating back to the screen, do not trigger a reload
    if (history.action === 'POP' && statusIds.size > 0) {
      return;
    }

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
      <StatusList
        trackScroll
        alwaysPrepend
        timelineId='explore'
        statusIds={statusIds}
        scrollKey='explore-statuses'
        hasMore={hasMore}
        isLoading={isLoading}
        onLoadMore={this.handleLoadMore}
        emptyMessage={emptyMessage}
        bindToDocument={!multiColumn}
        withCounters
      />
    );
  }

}

export default connect(mapStateToProps)(withRouter(Statuses));

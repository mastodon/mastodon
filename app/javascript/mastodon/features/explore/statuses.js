import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import StatusList from 'mastodon/components/status_list';
import { FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import { fetchTrendingStatuses } from 'mastodon/actions/trends';

const mapStateToProps = state => ({
  statusIds: state.getIn(['status_lists', 'trending', 'items']),
  isLoading: state.getIn(['status_lists', 'trending', 'isLoading'], true),
});

export default @connect(mapStateToProps)
class Statuses extends React.PureComponent {

  static propTypes = {
    statusIds: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
    multiColumn: PropTypes.bool,
    dispatch: PropTypes.func.isRequired,
  };

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(fetchTrendingStatuses());
  }

  render () {
    const { isLoading, statusIds, multiColumn } = this.props;

    const emptyMessage = <FormattedMessage id='empty_column.explore_statuses' defaultMessage='Nothing is trending right now. Check back later!' />;

    return (
      <StatusList
        trackScroll
        statusIds={statusIds}
        scrollKey='explore-statuses'
        hasMore={false}
        isLoading={isLoading}
        emptyMessage={emptyMessage}
        bindToDocument={!multiColumn}
        withCounters
      />
    );
  }

}

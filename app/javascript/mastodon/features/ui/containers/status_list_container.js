import { createSelector } from '@reduxjs/toolkit';
import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import { connect } from 'react-redux';

import { debounce } from 'lodash';

import { scrollTopTimeline, loadPending } from '@/mastodon/actions/timelines';
import { isNonStatusId } from '@/mastodon/actions/timelines_typed';
import StatusList from '@/mastodon/components/status_list';
import { me } from '@/mastodon/initial_state';

const makeGetStatusIds = (pending = false) => createSelector([
  (state, { type }) => state.getIn(['settings', type], ImmutableMap()),
  (state, { type }) => state.getIn(['timelines', type, pending ? 'pendingItems' : 'items'], ImmutableList()),
  (state)           => state.get('statuses'),
], (columnSettings, statusIds, statuses) => {
  return statusIds.filter(id => {
    if (isNonStatusId(id)) return true;

    const statusForId = statuses.get(id);

    if (statusForId.get('account') === me) return true;

    if (columnSettings.getIn(['shows', 'reblog']) === false && statusForId.get('reblog') !== null) {
      return false;
    }

    if (columnSettings.getIn(['shows', 'reply']) === false && statusForId.get('in_reply_to_id') !== null && statusForId.get('in_reply_to_account_id') !== me) {
      return false;
    }

    if (columnSettings.getIn(['shows', 'quote']) === false && statusForId.get('quote') !== null) {
      return false;
    }

    return true;
  });
});

const makeMapStateToProps = () => {
  const getStatusIds = makeGetStatusIds();
  const getPendingStatusIds = makeGetStatusIds(true);

  const mapStateToProps = (state, { timelineId, initialLoadingState = true }) => ({
    statusIds: getStatusIds(state, { type: timelineId }),
    lastId:    state.getIn(['timelines', timelineId, 'items'])?.last(),
    isLoading: state.getIn(['timelines', timelineId, 'isLoading'], initialLoadingState),
    isPartial: state.getIn(['timelines', timelineId, 'isPartial'], false),
    hasMore:   state.getIn(['timelines', timelineId, 'hasMore']),
    numPending: getPendingStatusIds(state, { type: timelineId }).size,
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { timelineId }) => ({

  onScrollToTop: debounce(() => {
    dispatch(scrollTopTimeline(timelineId, true));
  }, 100),

  onScroll: debounce(() => {
    dispatch(scrollTopTimeline(timelineId, false));
  }, 100),

  onLoadPending: () => dispatch(loadPending(timelineId)),

});

export default connect(makeMapStateToProps, mapDispatchToProps)(StatusList);

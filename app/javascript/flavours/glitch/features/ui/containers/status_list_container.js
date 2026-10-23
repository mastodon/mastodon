import { createSelector } from '@reduxjs/toolkit';
import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import { connect } from 'react-redux';

import { debounce } from 'lodash';

import { loadPending } from '@/flavours/glitch/actions/timelines';
import { isNonStatusId, timelineScroll } from '@/flavours/glitch/actions/timelines_typed';
import StatusList from '@/flavours/glitch/components/status_list';
import { me } from '@/flavours/glitch/initial_state';

const getRegex = createSelector([
  (state, { regex }) => regex,
], (rawRegex) => {
  let regex = null;

  try {
    regex = rawRegex && new RegExp(rawRegex.trim(), 'i');
  } catch {
    // Bad regex, don't affect filters
  }
  return regex;
});

const makeGetStatusIds = (pending = false) => createSelector([
  (state, { type }) => state.getIn(['settings', type], ImmutableMap()),
  (state, { type, maxItems }) => {
    const items = state.getIn(['timelines', type, pending ? 'pendingItems' : 'items'], ImmutableList());

    if (maxItems) {
      return items.take(maxItems);
    }

    return items;
  },
  (state)           => state.get('statuses'),
  getRegex,
], (columnSettings, statusIds, statuses, regex) => {
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

    if (columnSettings.getIn(['shows', 'direct']) === false && statusForId.get('visibility') === 'direct') {
      return false;
    }

    const searchIndex = statusForId.get('reblog') ? statuses.getIn([statusForId.get('reblog'), 'search_index']) : statusForId.get('search_index');
    if (regex && regex.test(searchIndex)) {
      return false;
    }

    return true;
  });
});

const makeMapStateToProps = () => {
  const getStatusIds = makeGetStatusIds();
  const getPendingStatusIds = makeGetStatusIds(true);

  /**
   * @param {import('flavours/glitch/store').RootState} state
   * @param {Object} props
   * @param {string} props.timelineId
   * @param {boolean} [props.initialLoadingState]
   * @param {number} [props.maxItems]
   * @param {RegExp} [props.regex]
   */
  const mapStateToProps = (state, { timelineId, regex, initialLoadingState = true, maxItems }) => ({
    statusIds: getStatusIds(state, { type: timelineId, regex, maxItems }),
    lastId:    state.getIn(['timelines', timelineId, 'items'])?.findLast(id => !isNonStatusId(id)),
    isLoading: state.getIn(['timelines', timelineId, 'isLoading'], initialLoadingState),
    isPartial: state.getIn(['timelines', timelineId, 'isPartial'], false),
    hasMore:   state.getIn(['timelines', timelineId, 'hasMore']),
    numPending: getPendingStatusIds(state, { type: timelineId }).size,
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { timelineId }) => ({

  onScrollToTop: debounce(() => {
    dispatch(timelineScroll({ timelineId, top: true }));
  }, 100),

  onScroll: debounce(() => {
    dispatch(timelineScroll({ timelineId, top: false }));
  }, 100),

  onLoadPending: () => dispatch(loadPending(timelineId)),

});

export default connect(makeMapStateToProps, mapDispatchToProps)(StatusList);

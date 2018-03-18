import { connect } from 'react-redux';
import StatusList from '../../../components/status_list';
import { scrollTopTimeline } from '../../../actions/timelines';
import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import { createSelector } from 'reselect';
import { debounce } from 'lodash';
import { me } from '../../../initial_state';

const makeGetStatusIds = () => createSelector([
  (state, { type }) => state.settings.get(type, ImmutableMap()),
  (state, { type }) => state.timelines.get([type, 'items'], ImmutableList()),
  (state)           => state.statuses,
], (columnSettings, statusIds, statuses) => {
  const rawRegex = columnSettings.getIn(['regex', 'body'], '').trim();
  let regex      = null;

  try {
    regex = rawRegex && new RegExp(rawRegex, 'i');
  } catch (e) {
    // Bad regex, don't affect filters
  }

  return statusIds.filter(id => {
    const statusForId = statuses.get(id);
    let showStatus    = true;

    if (columnSettings.getIn(['shows', 'reblog']) === false) {
      showStatus = showStatus && statusForId.get('reblog') === null;
    }

    if (columnSettings.getIn(['shows', 'reply']) === false) {
      showStatus = showStatus && (statusForId.get('in_reply_to_id') === null || statusForId.get('in_reply_to_account_id') === me);
    }

    if (showStatus && regex && statusForId.get('account') !== me) {
      const searchIndex = statusForId.get('reblog') ? statuses.getIn([statusForId.get('reblog'), 'search_index']) : statusForId.get('search_index');
      showStatus = !regex.test(searchIndex);
    }

    return showStatus;
  });
});

const makeMapStateToProps = () => {
  const getStatusIds = makeGetStatusIds();

  const mapStateToProps = (state, { timelineId }) => ({
    statusIds: getStatusIds(state, { type: timelineId }),
    isLoading: state.timelines.getIn([timelineId, 'isLoading'], true),
    isPartial: state.timelines.getIn([timelineId, 'isPartial'], false),
    hasMore: !!state.timelines.getIn([timelineId, 'next']),
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { timelineId, loadMore }) => ({

  onLoadMore: debounce(loadMore, 300, { leading: true }),

  onScrollToTop: debounce(() => {
    dispatch(scrollTopTimeline(timelineId, true));
  }, 100),

  onScroll: debounce(() => {
    dispatch(scrollTopTimeline(timelineId, false));
  }, 100),

});

export default connect(makeMapStateToProps, mapDispatchToProps)(StatusList);

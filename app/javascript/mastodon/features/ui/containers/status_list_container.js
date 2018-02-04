import { connect } from 'react-redux';
import StatusList from '../../../components/status_list';
import { scrollTopTimeline } from '../../../actions/timelines';
import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import { createSelector } from 'reselect';
import { debounce } from 'lodash';

const makeGetStatusIds = () => createSelector([
  (state, { type }) => state.getIn(['settings', type], ImmutableMap()),
  (state, { type }) => state.getIn(['timelines', type, 'items'], ImmutableList()),
  (state)           => state.get('statuses'),
  (state)           => state.getIn(['meta', 'me']),
], (columnSettings, statusIds, statuses, me) => {
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
    isLoading: state.getIn(['timelines', timelineId, 'isLoading'], true),
    hasMore: !!state.getIn(['timelines', timelineId, 'next']),
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { timelineId, loadMore }) => ({

  onScrollToBottom: debounce(() => {
    dispatch(scrollTopTimeline(timelineId, false));
    loadMore();
  }, 300, { leading: true }),

  onScrollToTop: debounce(() => {
    dispatch(scrollTopTimeline(timelineId, true));
  }, 100),

  onScroll: debounce(() => {
    dispatch(scrollTopTimeline(timelineId, false));
  }, 100),

});

export default connect(makeMapStateToProps, mapDispatchToProps)(StatusList);

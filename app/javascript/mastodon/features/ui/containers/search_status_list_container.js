import { connect } from 'react-redux';
import SearchStatusList from '../../../components/search_status_list';
import { expandTimeline, scrollTopTimeline } from '../../../actions/timelines';
import Immutable from 'immutable';
import { createSelector } from 'reselect';
import { debounce } from 'lodash';

const makeGetStatusIds = () => createSelector([
  (state, { type }) => state.getIn(['settings', type], Immutable.Map()),
  (state, { type }) => state.getIn(['timelines', type, 'items'], Immutable.List()),
  (state)           => state.get('statuses'),
  (state)           => state.getIn(['meta', 'me'])
], (columnSettings, statusIds, statuses, me) => statusIds.filter(id => {
  const statusForId = statuses.get(id);
  let showStatus    = true;

  if (columnSettings.getIn(['shows', 'reblog']) === false) {
    showStatus = showStatus && statusForId.get('reblog') === null;
  }

  if (columnSettings.getIn(['shows', 'reply']) === false) {
    showStatus = showStatus && (statusForId.get('in_reply_to_id') === null || statusForId.get('in_reply_to_account_id') === me);
  }

  if (columnSettings.getIn(['regex', 'body'], '').trim().length > 0) {
    try {
      if (showStatus) {
        const regex = new RegExp(columnSettings.getIn(['regex', 'body']).trim(), 'i');
        showStatus = !regex.test(statusForId.get('reblog') ? statuses.getIn([statusForId.get('reblog'), 'unescaped_content']) : statusForId.get('unescaped_content'));
      }
    } catch(e) {
      // Bad regex, don't affect filters
    }
  }

  return showStatus;
}));

const makeMapStateToProps = () => {
  const getStatusIds = makeGetStatusIds();

  const mapStateToProps = (state, props) => ({
    scrollKey: props.scrollKey,
    shouldUpdateScroll: props.shouldUpdateScroll,
    statusIds: getStatusIds(state, props),
    isLoading: state.getIn(['timelines', props.type, 'isLoading'], true),
    isUnread: state.getIn(['timelines', props.type, 'unread']) > 0,
    hasMore: !!state.getIn(['timelines', props.type, 'next'])
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { type, id }) => ({

  onScrollToBottom: debounce(() => {
    const query = $('.search-timeline .search__input').val();
    dispatch(scrollTopTimeline(type, false));
    dispatch(expandTimeline(type, query));
  }, 300, {leading: true}),

  onScrollToTop: debounce(() => {
    dispatch(scrollTopTimeline(type, true));
  }, 100),

  onScroll: debounce(() => {
    dispatch(scrollTopTimeline(type, false));
  }, 100),

});

export default connect(makeMapStateToProps, mapDispatchToProps)(SearchStatusList);

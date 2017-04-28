import { connect } from 'react-redux';
import StatusList from '../../../components/status_list';
import { expandTimeline, scrollTopTimeline } from '../../../actions/timelines';
import Immutable from 'immutable';
import { createSelector } from 'reselect';
import { debounce } from 'react-decoration';

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

  @debounce(300, true)
  onScrollToBottom () {
    dispatch(scrollTopTimeline(type, false));
    dispatch(expandTimeline(type, id));
  },

  @debounce(100)
  onScrollToTop () {
    dispatch(scrollTopTimeline(type, true));
  },

  @debounce(100)
  onScroll () {
    dispatch(scrollTopTimeline(type, false));
  }

});

export default connect(makeMapStateToProps, mapDispatchToProps)(StatusList);

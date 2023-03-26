import { connect } from 'react-redux';
import { List as ImmutableList } from 'immutable';
import StatusList from '../../../components/status_list';

const emptyList = ImmutableList();

const mapStateToProps = (state, { accountId, withReplies, withReblogs, tagged, forceEmptyState }) => {
  const path = `${accountId}${withReplies ? ':with_replies' : ''}${withReblogs ? ':with_reblogs' : ''}${tagged ? `:${tagged}` : ''}`;

  return {
    statusIds: forceEmptyState ? emptyList : state.getIn(['timelines', `account:${path}`, 'items'], emptyList),
    isLoading: state.getIn(['timelines', `account:${path}`, 'isLoading']),
    hasMore: !forceEmptyState && state.getIn(['timelines', `account:${path}`, 'hasMore']),
  };
};

export default connect(mapStateToProps)(StatusList);

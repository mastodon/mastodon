import { connect } from 'react-redux';
import ConversationsList from '../components/conversations_list';
import { expandConversations } from '../../../actions/conversations';

const mapStateToProps = state => ({
  conversationIds: state.getIn(['conversations', 'items']).map(x => x.get('id')),
  isLoading: state.getIn(['conversations', 'isLoading'], true),
  hasMore: state.getIn(['conversations', 'hasMore'], false),
});

const mapDispatchToProps = dispatch => ({
  onLoadMore: maxId => dispatch(expandConversations({ maxId })),
});

export default connect(mapStateToProps, mapDispatchToProps)(ConversationsList);

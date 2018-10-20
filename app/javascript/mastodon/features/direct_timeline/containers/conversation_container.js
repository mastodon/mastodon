import { connect } from 'react-redux';
import Conversation from '../components/conversation';
import { markConversationRead } from '../../../actions/conversations';

const mapStateToProps = (state, { conversationId }) => {
  const conversation = state.getIn(['conversations', 'items']).find(x => x.get('id') === conversationId);

  return {
    accounts: conversation.get('accounts').map(accountId => state.getIn(['accounts', accountId], null)),
    unread: conversation.get('unread'),
    lastStatusId: conversation.get('last_status', null),
  };
};

const mapDispatchToProps = (dispatch, { conversationId }) => ({
  markRead: () => dispatch(markConversationRead(conversationId)),
});

export default connect(mapStateToProps, mapDispatchToProps)(Conversation);

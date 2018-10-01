import { connect } from 'react-redux';
import Conversation from '../components/conversation';

const mapStateToProps = (state, { conversationId }) => {
  const conversation = state.getIn(['conversations', 'items']).find(x => x.get('id') === conversationId);
  const lastStatus   = state.getIn(['statuses', conversation.get('last_status')], null);

  return {
    accounts: conversation.get('accounts').map(accountId => state.getIn(['accounts', accountId], null)),
    lastStatus,
    lastAccount: lastStatus === null ? null : state.getIn(['accounts', lastStatus.get('account')], null),
  };
};

export default connect(mapStateToProps)(Conversation);

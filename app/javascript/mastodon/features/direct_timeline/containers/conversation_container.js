import { connect } from 'react-redux';
import { createSelector } from 'reselect';
import Conversation from '../components/conversation';
import { markConversationRead, deleteConversation } from 'mastodon/actions/conversations';
import { makeGetStatus } from 'mastodon/selectors';
import { replyCompose } from 'mastodon/actions/compose';
import { openModal } from 'mastodon/actions/modal';
import { muteStatus, unmuteStatus, hideStatus, revealStatus } from 'mastodon/actions/statuses';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  replyConfirm: { id: 'confirmations.reply.confirm', defaultMessage: 'Reply' },
  replyMessage: { id: 'confirmations.reply.message', defaultMessage: 'Replying now will overwrite the message you are currently composing. Are you sure you want to proceed?' },
});

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();
  const getAccounts = createSelector(
    [
      state => state.get('accounts'),
      (_, conversation) => conversation.get('accounts'),
    ],
    (accounts, accountIds) => accountIds.map(accountId => accounts.get(accountId, null))
  );

  return (state, { conversation }) => {
    const lastStatusId = conversation.get('last_status', null);

    return {
      accounts: getAccounts(state, conversation),
      unread: conversation.get('unread'),
      lastStatus: lastStatusId && getStatus(state, { id: lastStatusId }),
    };
  };
};

const mapDispatchToProps = (dispatch, { intl, conversation }) => ({

  markRead () {
    dispatch(markConversationRead(conversation.get('id')));
  },

  reply (status, router) {
    dispatch((_, getState) => {
      let state = getState();

      if (state.getIn(['compose', 'text']).trim().length !== 0) {
        dispatch(openModal('CONFIRM', {
          message: intl.formatMessage(messages.replyMessage),
          confirm: intl.formatMessage(messages.replyConfirm),
          onConfirm: () => dispatch(replyCompose(status, router)),
        }));
      } else {
        dispatch(replyCompose(status, router));
      }
    });
  },

  delete () {
    dispatch(deleteConversation(conversation.get('id')));
  },

  onMute (status) {
    if (status.get('muted')) {
      dispatch(unmuteStatus(status.get('id')));
    } else {
      dispatch(muteStatus(status.get('id')));
    }
  },

  onToggleHidden (status) {
    if (status.get('hidden')) {
      dispatch(revealStatus(status.get('id')));
    } else {
      dispatch(hideStatus(status.get('id')));
    }
  },

});

export default injectIntl(connect(makeMapStateToProps, mapDispatchToProps)(Conversation));

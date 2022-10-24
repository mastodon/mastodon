import { connect } from 'react-redux';
import { defineMessages, injectIntl } from 'react-intl';
import { makeGetAccount } from 'mastodon/selectors';
import { openModal } from 'mastodon/actions/modal';
import {
  groupKick,
  groupBlock,
  groupPromoteAccount,
  groupDemoteAccount,
} from 'mastodon/actions/groups';
import Membership from '../components/membership';

const messages = defineMessages({
  kickFromGroupMessage: { id: 'confirmations.kick_from_group.message', defaultMessage: 'Are you sure you want to kick @{name} from this group?' },
  kickConfirm: { id: 'confirmations.kick_from_group.confirm', defaultMessage: 'Kick' },
  blockFromGroupMessage: { id: 'confirmations.block_from_group.message', defaultMessage: 'Are you sure you want to block @{name} from interacting with this group?' },
  blockConfirm: { id: 'confirmations.block_from_group.confirm', defaultMessage: 'Block' },
  promoteConfirmMessage: { id: 'confirmations.promote_in_group.message', defaultMessage: 'Are you sure you want to promote @{name}? You will not be able to demote them.' },
  promoteConfirm: { id: 'confirmations.promote_in_group.confirm', defaultMessage: 'Promote' },
});

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, { accountId }) => ({
    account: getAccount(state, accountId),
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { groupId, intl }) => ({

  onKickFromGroup (account) {
    dispatch(openModal('CONFIRM', {
      message: intl.formatMessage(messages.kickFromGroupMessage, { name: account.get('username') }),
      confirm: intl.formatMessage(messages.kickConfirm),
      onConfirm: () => dispatch(groupKick(groupId, account.get('id'))),
    }));
  },

  onBlockFromGroup (account) {
    dispatch(openModal('CONFIRM', {
      message: intl.formatMessage(messages.blockFromGroupMessage, { name: account.get('username') }),
      confirm: intl.formatMessage(messages.blockConfirm),
      onConfirm: () => dispatch(groupBlock(groupId, account.get('id'))),
    }));
  },

  onPromote (account, role, warning) {
    if (warning) {
      dispatch(openModal('CONFIRM', {
        message: intl.formatMessage(messages.promoteConfirmMessage, { name: account.get('username') }),
        confirm: intl.formatMessage(messages.promoteConfirm),
        onConfirm: () => dispatch(groupPromoteAccount(groupId, account.get('id'), role)),
      }));
    } else {
      dispatch(groupPromoteAccount(groupId, account.get('id'), role));
    }
  },

  onDemote (account, role) {
    dispatch(groupDemoteAccount(groupId, account.get('id'), role));
  },

});

export default injectIntl(connect(makeMapStateToProps, mapDispatchToProps)(Membership));

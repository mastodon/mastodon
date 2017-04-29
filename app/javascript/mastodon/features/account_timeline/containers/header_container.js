import { connect } from 'react-redux';
import { makeGetAccount } from '../../../selectors';
import Header from '../components/header';
import {
  followAccount,
  unfollowAccount,
  blockAccount,
  unblockAccount,
  muteAccount,
  unmuteAccount
} from '../../../actions/accounts';
import { mentionCompose } from '../../../actions/compose';
import { initReport } from '../../../actions/reports';
import { openModal } from '../../../actions/modal';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

const messages = defineMessages({
  blockConfirm: { id: 'confirmations.block.confirm', defaultMessage: 'Block' },
  muteConfirm: { id: 'confirmations.mute.confirm', defaultMessage: 'Mute' }
});

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, { accountId }) => ({
    account: getAccount(state, Number(accountId)),
    me: state.getIn(['meta', 'me'])
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { intl }) => ({
  onFollow (account) {
    if (account.getIn(['relationship', 'following'])) {
      dispatch(unfollowAccount(account.get('id')));
    } else {
      dispatch(followAccount(account.get('id')));
    }
  },

  onBlock (account) {
    if (account.getIn(['relationship', 'blocking'])) {
      dispatch(unblockAccount(account.get('id')));
    } else {
      dispatch(openModal('CONFIRM', {
        message: <FormattedMessage id='confirmations.block.message' defaultMessage='Are you sure you want to block {name}?' values={{ name: <strong>@{account.get('acct')}</strong> }} />,
        confirm: intl.formatMessage(messages.blockConfirm),
        onConfirm: () => dispatch(blockAccount(account.get('id')))
      }));
    }
  },

  onMention (account, router) {
    dispatch(mentionCompose(account, router));
  },

  onReport (account) {
    dispatch(initReport(account));
  },

  onMute (account) {
    if (account.getIn(['relationship', 'muting'])) {
      dispatch(unmuteAccount(account.get('id')));
    } else {
      dispatch(openModal('CONFIRM', {
        message: <FormattedMessage id='confirmations.mute.message' defaultMessage='Are you sure you want to mute {name}?' values={{ name: <strong>@{account.get('acct')}</strong> }} />,
        confirm: intl.formatMessage(messages.muteConfirm),
        onConfirm: () => dispatch(muteAccount(account.get('id')))
      }));
    }
  }
});

export default injectIntl(connect(makeMapStateToProps, mapDispatchToProps)(Header));

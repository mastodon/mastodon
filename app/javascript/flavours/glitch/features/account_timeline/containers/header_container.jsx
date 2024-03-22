import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { connect } from 'react-redux';

import {
  followAccount,
  unfollowAccount,
  unblockAccount,
  unmuteAccount,
  pinAccount,
  unpinAccount,
} from '../../../actions/accounts';
import { initBlockModal } from '../../../actions/blocks';
import {
  mentionCompose,
  directCompose,
} from '../../../actions/compose';
import { initDomainBlockModal, unblockDomain } from '../../../actions/domain_blocks';
import { openModal } from '../../../actions/modal';
import { initMuteModal } from '../../../actions/mutes';
import { initReport } from '../../../actions/reports';
import { makeGetAccount, getAccountHidden } from '../../../selectors';
import Header from '../components/header';

const messages = defineMessages({
  cancelFollowRequestConfirm: { id: 'confirmations.cancel_follow_request.confirm', defaultMessage: 'Withdraw request' },
  unfollowConfirm: { id: 'confirmations.unfollow.confirm', defaultMessage: 'Unfollow' },
  blockDomainConfirm: { id: 'confirmations.domain_block.confirm', defaultMessage: 'Block entire domain' },
});

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, { accountId }) => ({
    account: getAccount(state, accountId),
    domain: state.getIn(['meta', 'domain']),
    hidden: getAccountHidden(state, accountId),
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { intl }) => ({

  onFollow (account) {
    if (account.getIn(['relationship', 'following'])) {
      dispatch(openModal({
        modalType: 'CONFIRM',
        modalProps: {
          message: <FormattedMessage id='confirmations.unfollow.message' defaultMessage='Are you sure you want to unfollow {name}?' values={{ name: <strong>@{account.get('acct')}</strong> }} />,
          confirm: intl.formatMessage(messages.unfollowConfirm),
          onConfirm: () => dispatch(unfollowAccount(account.get('id'))),
        },
      }));
    } else if (account.getIn(['relationship', 'requested'])) {
      dispatch(openModal({
        modalType: 'CONFIRM',
        modalProps: {
          message: <FormattedMessage id='confirmations.cancel_follow_request.message' defaultMessage='Are you sure you want to withdraw your request to follow {name}?' values={{ name: <strong>@{account.get('acct')}</strong> }} />,
          confirm: intl.formatMessage(messages.cancelFollowRequestConfirm),
          onConfirm: () => dispatch(unfollowAccount(account.get('id'))),
        },
      }));
    } else {
      dispatch(followAccount(account.get('id')));
    }
  },

  onInteractionModal (account) {
    dispatch(openModal({
      modalType: 'INTERACTION',
      modalProps: {
        type: 'follow',
        accountId: account.get('id'),
        url: account.get('uri'),
      },
    }));
  },

  onBlock (account) {
    if (account.getIn(['relationship', 'blocking'])) {
      dispatch(unblockAccount(account.get('id')));
    } else {
      dispatch(initBlockModal(account));
    }
  },

  onMention (account, router) {
    dispatch(mentionCompose(account, router));
  },

  onDirect (account, router) {
    dispatch(directCompose(account, router));
  },

  onReblogToggle (account) {
    if (account.getIn(['relationship', 'showing_reblogs'])) {
      dispatch(followAccount(account.get('id'), { reblogs: false }));
    } else {
      dispatch(followAccount(account.get('id'), { reblogs: true }));
    }
  },

  onEndorseToggle (account) {
    if (account.getIn(['relationship', 'endorsed'])) {
      dispatch(unpinAccount(account.get('id')));
    } else {
      dispatch(pinAccount(account.get('id')));
    }
  },

  onNotifyToggle (account) {
    if (account.getIn(['relationship', 'notifying'])) {
      dispatch(followAccount(account.get('id'), { notify: false }));
    } else {
      dispatch(followAccount(account.get('id'), { notify: true }));
    }
  },

  onReport (account) {
    dispatch(initReport(account));
  },

  onMute (account) {
    if (account.getIn(['relationship', 'muting'])) {
      dispatch(unmuteAccount(account.get('id')));
    } else {
      dispatch(initMuteModal(account));
    }
  },

  onBlockDomain (account) {
    dispatch(initDomainBlockModal(account));
  },

  onUnblockDomain (domain) {
    dispatch(unblockDomain(domain));
  },

  onAddToList (account) {
    dispatch(openModal({
      modalType: 'LIST_ADDER',
      modalProps: {
        accountId: account.get('id'),
      },
    }));
  },

  onChangeLanguages (account) {
    dispatch(openModal({
      modalType: 'SUBSCRIBED_LANGUAGES',
      modalProps: {
        accountId: account.get('id'),
      },
    }));
  },

  onOpenAvatar (account) {
    dispatch(openModal({
      modalType: 'IMAGE',
      modalProps: {
        src: account.get('avatar'),
        alt: account.get('acct'),
      },
    }));
  },

});

export default injectIntl(connect(makeMapStateToProps, mapDispatchToProps)(Header));

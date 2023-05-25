import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { connect } from 'react-redux';

import { initEditAccountNote } from 'flavours/glitch/actions/account_notes';
import {
  followAccount,
  unfollowAccount,
  unblockAccount,
  unmuteAccount,
  pinAccount,
  unpinAccount,
} from 'flavours/glitch/actions/accounts';
import { initBlockModal } from 'flavours/glitch/actions/blocks';
import {
  mentionCompose,
  directCompose,
} from 'flavours/glitch/actions/compose';
import { blockDomain, unblockDomain } from 'flavours/glitch/actions/domain_blocks';
import { openModal } from 'flavours/glitch/actions/modal';
import { initMuteModal } from 'flavours/glitch/actions/mutes';
import { initReport } from 'flavours/glitch/actions/reports';
import { unfollowModal } from 'flavours/glitch/initial_state';
import { makeGetAccount, getAccountHidden } from 'flavours/glitch/selectors';

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
      if (unfollowModal) {
        dispatch(openModal({
          modalType: 'CONFIRM',
          modalProps: {
            message: <FormattedMessage id='confirmations.unfollow.message' defaultMessage='Are you sure you want to unfollow {name}?' values={{ name: <strong>@{account.get('acct')}</strong> }} />,
            confirm: intl.formatMessage(messages.unfollowConfirm),
            onConfirm: () => dispatch(unfollowAccount(account.get('id'))),
          },
        }));
      } else {
        dispatch(unfollowAccount(account.get('id')));
      }
    } else if (account.getIn(['relationship', 'requested'])) {
      if (unfollowModal) {
        dispatch(openModal({
          modalType: 'CONFIRM',
          modalProps: {
            message: <FormattedMessage id='confirmations.cancel_follow_request.message' defaultMessage='Are you sure you want to withdraw your request to follow {name}?' values={{ name: <strong>@{account.get('acct')}</strong> }} />,
            confirm: intl.formatMessage(messages.cancelFollowRequestConfirm),
            onConfirm: () => dispatch(unfollowAccount(account.get('id'))),
          },
        }));
      } else {
        dispatch(unfollowAccount(account.get('id')));
      }
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
        url: account.get('url'),
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

  onEditAccountNote (account) {
    dispatch(initEditAccountNote(account));
  },

  onBlockDomain (domain) {
    dispatch(openModal({
      modalType: 'CONFIRM',
      modalProps: {
        message: <FormattedMessage id='confirmations.domain_block.message' defaultMessage='Are you really, really sure you want to block the entire {domain}? In most cases a few targeted blocks or mutes are sufficient and preferable.' values={{ domain: <strong>{domain}</strong> }} />,
        confirm: intl.formatMessage(messages.blockDomainConfirm),
        onConfirm: () => dispatch(blockDomain(domain)),
      },
    }));
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

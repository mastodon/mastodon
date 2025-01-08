import { injectIntl } from 'react-intl';

import { connect } from 'react-redux';

import { openURL } from 'mastodon/actions/search';

import {
  followAccount,
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

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, { accountId }) => ({
    account: getAccount(state, accountId),
    domain: state.getIn(['meta', 'domain']),
    hidden: getAccountHidden(state, accountId),
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch) => ({

  onFollow (account) {
    if (account.getIn(['relationship', 'following']) || account.getIn(['relationship', 'requested'])) {
      dispatch(openModal({ modalType: 'CONFIRM_UNFOLLOW', modalProps: { account } }));
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

  onMention (account) {
    dispatch(mentionCompose(account));
  },

  onDirect (account) {
    dispatch(directCompose(account));
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
        alt: '',
      },
    }));
  },

  onOpenURL (url) {
    return dispatch(openURL({ url }));
  },

});

export default injectIntl(connect(makeMapStateToProps, mapDispatchToProps)(Header));

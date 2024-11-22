import { injectIntl } from 'react-intl';

import { connect } from 'react-redux';

import { openModal } from 'mastodon/actions/modal';

import {
  followAccount,
  blockAccount,
  unblockAccount,
  muteAccount,
  unmuteAccount,
} from '../actions/accounts';
import { initMuteModal } from '../actions/mutes';
import Account from '../components/account';
import { makeGetAccount } from '../selectors';

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, props) => ({
    account: getAccount(state, props.id),
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

  onBlock (account) {
    if (account.getIn(['relationship', 'blocking'])) {
      dispatch(unblockAccount(account.get('id')));
    } else {
      dispatch(blockAccount(account.get('id')));
    }
  },

  onMute (account) {
    if (account.getIn(['relationship', 'muting'])) {
      dispatch(unmuteAccount(account.get('id')));
    } else {
      dispatch(initMuteModal(account));
    }
  },


  onMuteNotifications (account, notifications) {
    dispatch(muteAccount(account.get('id'), notifications));
  },
});

export default injectIntl(connect(makeMapStateToProps, mapDispatchToProps)(Account));

import { connect } from 'react-redux';
import { makeGetAccount } from '../../../selectors';
import Header from '../components/header';
import {
  followAccount,
  unfollowAccount,
  blockAccount,
  unblockAccount
} from '../../../actions/accounts';
import { mentionCompose } from '../../../actions/compose';

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, { accountId }) => ({
    account: getAccount(state, Number(accountId)),
    me: state.getIn(['meta', 'me'])
  });

  return mapStateToProps;
};

const mapDispatchToProps = dispatch => ({
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
      dispatch(blockAccount(account.get('id')));
    }
  },

  onMention (account, router) {
    dispatch(mentionCompose(account, router));
  }
});

export default connect(makeMapStateToProps, mapDispatchToProps)(Header);

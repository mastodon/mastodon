import { connect }            from 'react-redux';
import { makeGetAccount }     from '../../../selectors';
import Account                from '../components/account';
import {
  followAccount,
  unfollowAccount
}                             from '../../../actions/accounts';

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, props) => ({
    account: getAccount(state, props.id),
    me: state.getIn(['meta', 'me'])
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch) => ({
  onFollow (account) {
    if (account.getIn(['relationship', 'following'])) {
      dispatch(unfollowAccount(account.get('id')));
    } else {
      dispatch(followAccount(account.get('id')));
    }
  }
});

export default connect(makeMapStateToProps, mapDispatchToProps)(Account);

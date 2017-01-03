import { connect } from 'react-redux';
import { makeGetAccount } from '../../../selectors';
import AccountAuthorize from '../components/account_authorize';
import { authorizeFollowRequest, rejectFollowRequest } from '../../../actions/accounts';

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, props) => ({
    account: getAccount(state, props.id)
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { id }) => ({
  onAuthorize (account) {
    dispatch(authorizeFollowRequest(id));
  },

  onReject (account) {
    dispatch(rejectFollowRequest(id));
  }
});

export default connect(makeMapStateToProps, mapDispatchToProps)(AccountAuthorize);

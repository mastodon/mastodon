import { connect } from 'react-redux';
import { makeGetAccount } from 'flavours/glitch/selectors';
import AccountAuthorize from '../components/account_authorize';
import { authorizeFollowRequest, rejectFollowRequest } from 'flavours/glitch/actions/accounts';

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, props) => ({
    account: getAccount(state, props.id),
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { id }) => ({
  onAuthorize () {
    dispatch(authorizeFollowRequest(id));
  },

  onReject () {
    dispatch(rejectFollowRequest(id));
  },
});

export default connect(makeMapStateToProps, mapDispatchToProps)(AccountAuthorize);

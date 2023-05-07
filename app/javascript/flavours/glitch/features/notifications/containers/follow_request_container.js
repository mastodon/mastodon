import { connect } from 'react-redux';
import FollowRequest from '../components/follow_request';
import { authorizeFollowRequest, rejectFollowRequest } from 'flavours/glitch/actions/accounts';

const mapDispatchToProps = (dispatch, { account }) => ({
  onAuthorize () {
    dispatch(authorizeFollowRequest(account.get('id')));
  },

  onReject () {
    dispatch(rejectFollowRequest(account.get('id')));
  },
});

export default connect(null, mapDispatchToProps)(FollowRequest);

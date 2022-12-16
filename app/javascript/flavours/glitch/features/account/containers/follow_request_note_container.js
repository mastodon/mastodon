import { connect } from 'react-redux';
import FollowRequestNote from '../components/follow_request_note';
import { authorizeFollowRequest, rejectFollowRequest } from 'flavours/glitch/actions/accounts';

const mapDispatchToProps = (dispatch, { account }) => ({
  onAuthorize () {
    dispatch(authorizeFollowRequest(account.get('id')));
  },

  onReject () {
    dispatch(rejectFollowRequest(account.get('id')));
  },
});

export default connect(null, mapDispatchToProps)(FollowRequestNote);

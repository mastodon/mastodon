import { connect } from 'react-redux';

import { authorizeFollowRequest, rejectFollowRequest } from 'flavours/glitch/actions/accounts';

import FollowRequestNote from '../components/follow_request_note';

const mapDispatchToProps = (dispatch, { account }) => ({
  onAuthorize () {
    dispatch(authorizeFollowRequest(account.get('id')));
  },

  onReject () {
    dispatch(rejectFollowRequest(account.get('id')));
  },
});

export default connect(null, mapDispatchToProps)(FollowRequestNote);

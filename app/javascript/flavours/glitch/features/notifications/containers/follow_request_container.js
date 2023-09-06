import { connect } from 'react-redux';

import { authorizeFollowRequest, rejectFollowRequest } from 'flavours/glitch/actions/accounts';

import FollowRequest from '../components/follow_request';

const mapDispatchToProps = (dispatch, { account }) => ({
  onAuthorize () {
    dispatch(authorizeFollowRequest(account.get('id')));
  },

  onReject () {
    dispatch(rejectFollowRequest(account.get('id')));
  },
});

export default connect(null, mapDispatchToProps)(FollowRequest);

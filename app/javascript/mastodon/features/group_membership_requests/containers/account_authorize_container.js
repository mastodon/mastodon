import { connect } from 'react-redux';
import { makeGetAccount } from 'mastodon/selectors';
import AccountAuthorize from 'mastodon/features/follow_requests/components/account_authorize';
import { authorizeGroupMembershipRequest, rejectGroupMembershipRequest } from 'mastodon/actions/groups';

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, props) => ({
    account: getAccount(state, props.id),
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { id, groupId }) => ({
  onAuthorize () {
    dispatch(authorizeGroupMembershipRequest(groupId, id));
  },

  onReject () {
    dispatch(rejectGroupMembershipRequest(groupId, id));
  },
});

export default connect(makeMapStateToProps, mapDispatchToProps)(AccountAuthorize);

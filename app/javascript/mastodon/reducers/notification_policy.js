import { fromJS } from 'immutable';

import { NOTIFICATION_POLICY_FETCH_SUCCESS } from 'mastodon/actions/notifications';

export const notificationPolicyReducer = (state = null, action) => {
  switch(action.type) {
  case NOTIFICATION_POLICY_FETCH_SUCCESS:
    return fromJS(action.policy);
  default:
    return state;
  }
};

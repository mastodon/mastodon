import { COMPOSE_SUBMIT_FAIL, COMPOSE_UPLOAD_FAIL } from '../actions/compose';
import { FOLLOW_SUBMIT_FAIL }                       from '../actions/follow';
import { REBLOG_FAIL, FAVOURITE_FAIL }              from '../actions/interactions';
import {
  TIMELINE_REFRESH_FAIL,
  TIMELINE_EXPAND_FAIL
}                                                   from '../actions/timelines';
import { NOTIFICATION_DISMISS, NOTIFICATION_CLEAR } from '../actions/notifications';
import {
  ACCOUNT_FETCH_FAIL,
  ACCOUNT_FOLLOW_FAIL,
  ACCOUNT_UNFOLLOW_FAIL,
  ACCOUNT_TIMELINE_FETCH_FAIL,
  ACCOUNT_TIMELINE_EXPAND_FAIL
}                                                   from '../actions/accounts';
import {
  STATUS_FETCH_FAIL,
  STATUS_DELETE_FAIL
}                                                   from '../actions/statuses';
import Immutable                                    from 'immutable';

const initialState = Immutable.List();

function notificationFromError(state, error) {
  let n = Immutable.Map({
    key: state.size > 0 ? state.last().get('key') + 1 : 0,
    message: ''
  });

  if (error.response) {
    n = n.withMutations(map => {
      map.set('message', error.response.statusText);
      map.set('title', `${error.response.status}`);
    });
  } else {
    n = n.set('message', `${error}`);
  }

  return state.push(n);
};

export default function notifications(state = initialState, action) {
  switch(action.type) {
    case COMPOSE_SUBMIT_FAIL:
    case COMPOSE_UPLOAD_FAIL:
    case FOLLOW_SUBMIT_FAIL:
    case REBLOG_FAIL:
    case FAVOURITE_FAIL:
    case TIMELINE_REFRESH_FAIL:
    case TIMELINE_EXPAND_FAIL:
    case ACCOUNT_FETCH_FAIL:
    case ACCOUNT_FOLLOW_FAIL:
    case ACCOUNT_UNFOLLOW_FAIL:
    case ACCOUNT_TIMELINE_FETCH_FAIL:
    case ACCOUNT_TIMELINE_EXPAND_FAIL:
    case STATUS_FETCH_FAIL:
    case STATUS_DELETE_FAIL:
      return notificationFromError(state, action.error);
    case NOTIFICATION_DISMISS:
      return state.filterNot(item => item.get('key') === action.notification.key);
    case NOTIFICATION_CLEAR:
      return state.clear();
    default:
      return state;
  }
};

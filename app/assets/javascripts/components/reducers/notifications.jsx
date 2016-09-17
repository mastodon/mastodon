import { COMPOSE_SUBMIT_FAIL, COMPOSE_UPLOAD_FAIL } from '../actions/compose';
import { FOLLOW_SUBMIT_FAIL }                       from '../actions/follow';
import { REBLOG_FAIL, FAVOURITE_FAIL }              from '../actions/interactions';
import { TIMELINE_REFRESH_FAIL }                    from '../actions/timelines';
import { NOTIFICATION_DISMISS }                     from '../actions/notifications';
import Immutable                                    from 'immutable';

const initialState = Immutable.List();

function notificationFromError(state, error) {
  let n = Immutable.Map({
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

export default function meta(state = initialState, action) {
  switch(action.type) {
    case COMPOSE_SUBMIT_FAIL:
    case COMPOSE_UPLOAD_FAIL:
    case FOLLOW_SUBMIT_FAIL:
    case REBLOG_FAIL:
    case FAVOURITE_FAIL:
    case TIMELINE_REFRESH_FAIL:
      return notificationFromError(state, action.error);
    case NOTIFICATION_DISMISS:
      return state.clear();
    default:
      return state;
  }
};

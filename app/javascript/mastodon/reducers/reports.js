import {
  REPORT_INIT,
  REPORT_SUBMIT_REQUEST,
  REPORT_SUBMIT_SUCCESS,
  REPORT_SUBMIT_FAIL,
  REPORT_CANCEL,
  REPORT_STATUS_TOGGLE,
  REPORT_COMMENT_CHANGE,
  REPORT_FORWARD_CHANGE,
} from '../actions/reports';
import { Map as ImmutableMap, Set as ImmutableSet } from 'immutable';

const initialState = ImmutableMap({
  new: ImmutableMap({
    isSubmitting: false,
    account_id: null,
    status_ids: ImmutableSet(),
    comment: '',
    forward: false,
  }),
});

export default function reports(state = initialState, action) {
  switch(action.type) {
  case REPORT_INIT:
    return state.withMutations(map => {
      map.setIn(['new', 'isSubmitting'], false);
      map.setIn(['new', 'account_id'], action.account.get('id'));

      if (state.getIn(['new', 'account_id']) !== action.account.get('id')) {
        map.setIn(['new', 'status_ids'], action.status ? ImmutableSet([action.status.getIn(['reblog', 'id'], action.status.get('id'))]) : ImmutableSet());
        map.setIn(['new', 'comment'], '');
      } else if (action.status) {
        map.updateIn(['new', 'status_ids'], ImmutableSet(), set => set.add(action.status.getIn(['reblog', 'id'], action.status.get('id'))));
      }
    });
  case REPORT_STATUS_TOGGLE:
    return state.updateIn(['new', 'status_ids'], ImmutableSet(), set => {
      if (action.checked) {
        return set.add(action.statusId);
      }

      return set.remove(action.statusId);
    });
  case REPORT_COMMENT_CHANGE:
    return state.setIn(['new', 'comment'], action.comment);
  case REPORT_FORWARD_CHANGE:
    return state.setIn(['new', 'forward'], action.forward);
  case REPORT_SUBMIT_REQUEST:
    return state.setIn(['new', 'isSubmitting'], true);
  case REPORT_SUBMIT_FAIL:
    return state.setIn(['new', 'isSubmitting'], false);
  case REPORT_CANCEL:
  case REPORT_SUBMIT_SUCCESS:
    return state.withMutations(map => {
      map.setIn(['new', 'account_id'], null);
      map.setIn(['new', 'status_ids'], ImmutableSet());
      map.setIn(['new', 'comment'], '');
      map.setIn(['new', 'isSubmitting'], false);
    });
  default:
    return state;
  }
};

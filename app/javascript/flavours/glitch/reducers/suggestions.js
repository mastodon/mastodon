import { Map as ImmutableMap, List as ImmutableList, fromJS } from 'immutable';

import { blockAccountSuccess, muteAccountSuccess } from 'flavours/glitch/actions/accounts';
import { blockDomainSuccess } from 'flavours/glitch/actions/domain_blocks';

import {
  SUGGESTIONS_FETCH_REQUEST,
  SUGGESTIONS_FETCH_SUCCESS,
  SUGGESTIONS_FETCH_FAIL,
  SUGGESTIONS_DISMISS,
} from '../actions/suggestions';


const initialState = ImmutableMap({
  items: ImmutableList(),
  isLoading: false,
});

export default function suggestionsReducer(state = initialState, action) {
  switch(action.type) {
  case SUGGESTIONS_FETCH_REQUEST:
    return state.set('isLoading', true);
  case SUGGESTIONS_FETCH_SUCCESS:
    return state.withMutations(map => {
      map.set('items', fromJS(action.suggestions.map(x => ({ ...x, account: x.account.id }))));
      map.set('isLoading', false);
    });
  case SUGGESTIONS_FETCH_FAIL:
    return state.set('isLoading', false);
  case SUGGESTIONS_DISMISS:
    return state.update('items', list => list.filterNot(x => x.get('account') === action.id));
  case blockAccountSuccess.type:
  case muteAccountSuccess.type:
    return state.update('items', list => list.filterNot(x => x.get('account') === action.payload.relationship.id));
  case blockDomainSuccess.type:
    return state.update('items', list => list.filterNot(x => action.payload.accounts.includes(x.get('account'))));
  default:
    return state;
  }
}

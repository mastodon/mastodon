import { SUGGESTIONS_FETCH_SUCCESS } from '../actions/suggestions';
import Immutable                     from 'immutable';

const initialState = Immutable.List();

export default function suggestions(state = initialState, action) {
  switch(action.type) {
    case SUGGESTIONS_FETCH_SUCCESS:
      return Immutable.List(action.accounts.map(item => item.id));
    default:
      return state;
  }
}

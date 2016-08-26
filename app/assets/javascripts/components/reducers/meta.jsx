import { SET_ACCESS_TOKEN }         from '../actions/meta';
import Immutable                    from 'immutable';

const initialState = Immutable.Map();

export default function meta(state = initialState, action) {
  switch(action.type) {
    case SET_ACCESS_TOKEN:
      return state.set('access_token', action.token);
    default:
      return state;
  }
}

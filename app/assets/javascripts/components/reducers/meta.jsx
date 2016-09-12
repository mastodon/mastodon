import { ACCESS_TOKEN_SET }         from '../actions/meta';
import Immutable                    from 'immutable';

const initialState = Immutable.Map();

export default function meta(state = initialState, action) {
  switch(action.type) {
    case ACCESS_TOKEN_SET:
      return state.set('access_token', action.token);
    default:
      return state;
  }
};

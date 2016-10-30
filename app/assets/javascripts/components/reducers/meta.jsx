import { ACCESS_TOKEN_SET } from '../actions/meta';
import { ACCOUNT_SET_SELF } from '../actions/accounts';
import Immutable from 'immutable';

const initialState = Immutable.Map();

export default function meta(state = initialState, action) {
  switch(action.type) {
    case ACCESS_TOKEN_SET:
      return state.set('access_token', action.token);
    case ACCOUNT_SET_SELF:
      return state.set('me', action.account.id);
    default:
      return state;
  }
};

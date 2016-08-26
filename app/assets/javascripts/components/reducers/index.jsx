import { combineReducers } from 'redux-immutable';
import statuses            from './statuses';
import meta                from './meta';

export default combineReducers({
  statuses,
  meta
});

import { GROUPS_IMPORT } from 'mastodon/actions/importer';
import { GROUP_FETCH_FAIL, GROUP_DELETE_SUCCESS } from 'mastodon/actions/groups';
import { Map as ImmutableMap, fromJS } from 'immutable';

const normalizeGroup = (state, group) => state.set(group.id, fromJS(group));
const importGroups = (state, groups) => state.withMutations(map => groups.forEach(group => normalizeGroup(map, group)));

const initialState = ImmutableMap();

export default function groups(state = initialState, action) {
  switch(action.type) {
  case GROUPS_IMPORT:
    return importGroups(state, action.groups);
  case GROUP_DELETE_SUCCESS:
  case GROUP_FETCH_FAIL:
    return state.set(action.id, false);
  default:
    return state;
  }
}

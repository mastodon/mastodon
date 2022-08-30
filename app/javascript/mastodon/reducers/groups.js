import { GROUPS_IMPORT } from 'mastodon/actions/importer';
import { Map as ImmutableMap, fromJS } from 'immutable';

const importGroups = (state, groups) => state.withMutations(map => groups.forEach(group => map.set(group.id, fromJS(group))));

const initialState = ImmutableMap();

export default function groups(state = initialState, action) {
  switch(action.type) {
  case GROUPS_IMPORT:
    return importGroups(state, action.groups);
  default:
    return state;
  }
}

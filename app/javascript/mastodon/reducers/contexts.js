import {
  ACCOUNT_BLOCK_SUCCESS,
  ACCOUNT_MUTE_SUCCESS,
} from '../actions/accounts';
import { CONTEXT_FETCH_SUCCESS } from '../actions/statuses';
import { TIMELINE_DELETE, TIMELINE_CONTEXT_UPDATE } from '../actions/timelines';
import { Map as ImmutableMap, List as ImmutableList } from 'immutable';

const initialState = ImmutableMap({
  ancestors: ImmutableMap(),
  descendants: ImmutableMap(),
});

const normalizeContext = (state, id, ancestors, descendants) => {
  const ancestorsIds   = ImmutableList(ancestors.map(ancestor => ancestor.id));
  const descendantsIds = ImmutableList(descendants.map(descendant => descendant.id));

  return state.withMutations(map => {
    map.setIn(['ancestors', id], ancestorsIds);
    map.setIn(['descendants', id], descendantsIds);
  });
};

const deleteFromContexts = (immutableState, ids) => immutableState.withMutations(state => {
  state.update('ancestors', immutableAncestors => immutableAncestors.withMutations(ancestors => {
    state.update('descendants', immutableDescendants => immutableDescendants.withMutations(descendants => {
      ids.forEach(id => {
        descendants.get(id, ImmutableList()).forEach(descendantId => {
          ancestors.update(descendantId, ImmutableList(), list => list.filterNot(itemId => itemId === id));
        });

        ancestors.get(id, ImmutableList()).forEach(ancestorId => {
          descendants.update(ancestorId, ImmutableList(), list => list.filterNot(itemId => itemId === id));
        });

        descendants.delete(id);
        ancestors.delete(id);
      });
    }));
  }));
});

const filterContexts = (state, relationship, statuses) => {
  const ownedStatusIds = statuses
    .filter(status => status.get('account') === relationship.id)
    .map(status => status.get('id'));

  return deleteFromContexts(state, ownedStatusIds);
};

const updateContext = (state, status, references) => {
  return state.update('descendants', map => {
    references.forEach(parentId => {
      map = map.update(parentId, ImmutableList(), list => {
        if (list.includes(status.id)) {
          return list;
        }

        return list.push(status.id);
      });
    });

    return map;
  });
};

export default function contexts(state = initialState, action) {
  switch(action.type) {
  case ACCOUNT_BLOCK_SUCCESS:
  case ACCOUNT_MUTE_SUCCESS:
    return filterContexts(state, action.relationship, action.statuses);
  case CONTEXT_FETCH_SUCCESS:
    return normalizeContext(state, action.id, action.ancestors, action.descendants);
  case TIMELINE_DELETE:
    return deleteFromContexts(state, [action.id]);
  case TIMELINE_CONTEXT_UPDATE:
    return updateContext(state, action.status, action.references);
  default:
    return state;
  }
};

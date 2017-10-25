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

const deleteFromContexts = (state, id) => {
  state.getIn(['descendants', id], ImmutableList()).forEach(descendantId => {
    state = state.updateIn(['ancestors', descendantId], ImmutableList(), list => list.filterNot(itemId => itemId === id));
  });

  state.getIn(['ancestors', id], ImmutableList()).forEach(ancestorId => {
    state = state.updateIn(['descendants', ancestorId], ImmutableList(), list => list.filterNot(itemId => itemId === id));
  });

  state = state.deleteIn(['descendants', id]).deleteIn(['ancestors', id]);

  return state;
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
  case CONTEXT_FETCH_SUCCESS:
    return normalizeContext(state, action.id, action.ancestors, action.descendants);
  case TIMELINE_DELETE:
    return deleteFromContexts(state, action.id);
  case TIMELINE_CONTEXT_UPDATE:
    return updateContext(state, action.status, action.references);
  default:
    return state;
  }
};

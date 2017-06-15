import { CONTEXT_FETCH_SUCCESS } from '../actions/statuses';
import { TIMELINE_DELETE } from '../actions/timelines';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  ancestors: Immutable.Map(),
  descendants: Immutable.Map(),
});

const normalizeContext = (state, id, ancestors, descendants) => {
  const ancestorsIds   = ancestors.map(ancestor => ancestor.get('id'));
  const descendantsIds = descendants.map(descendant => descendant.get('id'));

  return state.withMutations(map => {
    map.setIn(['ancestors', id], ancestorsIds);
    map.setIn(['descendants', id], descendantsIds);
  });
};

const deleteFromContexts = (state, id) => {
  state.getIn(['descendants', id], Immutable.List()).forEach(descendantId => {
    state = state.updateIn(['ancestors', descendantId], Immutable.List(), list => list.filterNot(itemId => itemId === id));
  });

  state.getIn(['ancestors', id], Immutable.List()).forEach(ancestorId => {
    state = state.updateIn(['descendants', ancestorId], Immutable.List(), list => list.filterNot(itemId => itemId === id));
  });

  state = state.deleteIn(['descendants', id]).deleteIn(['ancestors', id]);

  return state;
};

export default function contexts(state = initialState, action) {
  switch(action.type) {
  case CONTEXT_FETCH_SUCCESS:
    return normalizeContext(state, action.id, Immutable.fromJS(action.ancestors), Immutable.fromJS(action.descendants));
  case TIMELINE_DELETE:
    return deleteFromContexts(state, action.id);
  default:
    return state;
  }
};

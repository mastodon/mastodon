import { SETTING_CHANGE } from '../actions/settings';
import { COLUMN_ADD, COLUMN_REMOVE, COLUMN_MOVE } from '../actions/columns';
import { STORE_HYDRATE } from '../actions/store';
import Immutable from 'immutable';
import uuid from '../uuid';

const initialState = Immutable.Map({
  onboarded: false,

  columns: Immutable.fromJS([
    { id: 'COMPOSE', uuid: uuid(), params: {} },
    { id: 'HOME', uuid: uuid(), params: {} },
    { id: 'NOTIFICATIONS', uuid: uuid(), params: {} },
  ]),

  home: Immutable.Map({
    shows: Immutable.Map({
      reblog: true,
      reply: true,
    }),

    regex: Immutable.Map({
      body: '',
    }),
  }),

  notifications: Immutable.Map({
    alerts: Immutable.Map({
      follow: true,
      favourite: true,
      reblog: true,
      mention: true,
    }),

    shows: Immutable.Map({
      follow: true,
      favourite: true,
      reblog: true,
      mention: true,
    }),

    sounds: Immutable.Map({
      follow: true,
      favourite: true,
      reblog: true,
      mention: true,
    }),
  }),
});

const moveColumn = (state, uuid, direction) => {
  const columns  = state.get('columns');
  const index    = columns.findIndex(item => item.get('uuid') === uuid);
  const newIndex = index + direction;

  let newColumns;

  newColumns = columns.splice(index, 1);
  newColumns = newColumns.splice(newIndex, 0, columns.get(index));

  return state.set('columns', newColumns);
};

export default function settings(state = initialState, action) {
  switch(action.type) {
  case STORE_HYDRATE:
    return state.mergeDeep(action.state.get('settings'));
  case SETTING_CHANGE:
    return state.setIn(action.key, action.value);
  case COLUMN_ADD:
    return state.update('columns', list => list.push(Immutable.fromJS({ id: action.id, uuid: uuid(), params: action.params })));
  case COLUMN_REMOVE:
    return state.update('columns', list => list.filterNot(item => item.get('uuid') === action.uuid));
  case COLUMN_MOVE:
    return moveColumn(state, action.uuid, action.direction);
  default:
    return state;
  }
};

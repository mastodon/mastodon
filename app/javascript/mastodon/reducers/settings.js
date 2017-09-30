import { SETTING_CHANGE } from '../actions/settings';
import { COLUMN_ADD, COLUMN_REMOVE, COLUMN_MOVE } from '../actions/columns';
import { STORE_HYDRATE } from '../actions/store';
import { Map as ImmutableMap, fromJS } from 'immutable';
import uuid from '../uuid';

const initialState = ImmutableMap({
  onboarded: false,

  home: ImmutableMap({
    shows: ImmutableMap({
      reblog: true,
      reply: true,
    }),

    regex: ImmutableMap({
      body: '',
    }),
  }),

  notifications: ImmutableMap({
    alerts: ImmutableMap({
      follow: true,
      favourite: true,
      reblog: true,
      mention: true,
    }),

    shows: ImmutableMap({
      follow: true,
      favourite: true,
      reblog: true,
      mention: true,
    }),

    sounds: ImmutableMap({
      follow: true,
      favourite: true,
      reblog: true,
      mention: true,
    }),
  }),

  community: ImmutableMap({
    regex: ImmutableMap({
      body: '',
    }),
  }),

  public: ImmutableMap({
    regex: ImmutableMap({
      body: '',
    }),
  }),
});

const defaultColumns = fromJS([
  { id: 'COMPOSE', uuid: uuid(), params: {} },
  { id: 'HOME', uuid: uuid(), params: {} },
  { id: 'NOTIFICATIONS', uuid: uuid(), params: {} },
]);

const hydrate = (state, settings) => state.mergeDeep(settings).update('columns', (val = defaultColumns) => val);

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
    return hydrate(state, action.state.get('settings'));
  case SETTING_CHANGE:
    return state.setIn(action.key, action.value);
  case COLUMN_ADD:
    return state.update('columns', list => list.push(fromJS({ id: action.id, uuid: uuid(), params: action.params })));
  case COLUMN_REMOVE:
    return state.update('columns', list => list.filterNot(item => item.get('uuid') === action.uuid));
  case COLUMN_MOVE:
    return moveColumn(state, action.uuid, action.direction);
  default:
    return state;
  }
};

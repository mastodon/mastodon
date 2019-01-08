import { saveSettings } from './settings';

export const COLUMN_ADD           = 'COLUMN_ADD';
export const COLUMN_REMOVE        = 'COLUMN_REMOVE';
export const COLUMN_MOVE          = 'COLUMN_MOVE';
export const COLUMN_PARAMS_CHANGE = 'COLUMN_PARAMS_CHANGE';

export function addColumn(id, params) {
  return dispatch => {
    dispatch({
      type: COLUMN_ADD,
      id,
      params,
    });

    dispatch(saveSettings());
  };
};

export function removeColumn(uuid) {
  return dispatch => {
    dispatch({
      type: COLUMN_REMOVE,
      uuid,
    });

    dispatch(saveSettings());
  };
};

export function moveColumn(uuid, direction) {
  return dispatch => {
    dispatch({
      type: COLUMN_MOVE,
      uuid,
      direction,
    });

    dispatch(saveSettings());
  };
};

export function changeColumnParams(uuid, path, value) {
  return dispatch => {
    dispatch({
      type: COLUMN_PARAMS_CHANGE,
      uuid,
      path,
      value,
    });

    dispatch(saveSettings());
  };
}

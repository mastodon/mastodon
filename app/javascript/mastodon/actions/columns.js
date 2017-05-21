import { saveSettings } from './settings';

export const COLUMN_ADD    = 'COLUMN_ADD';
export const COLUMN_REMOVE = 'COLUMN_REMOVE';

export function addColumn(id, params) {
  return dispatch => {
    dispatch({
      type: COLUMN_ADD,
      id,
      params,
    });

    saveSettings();
  };
};

export function removeColumn(uuid) {
  return dispatch => {
    dispatch({
      type: COLUMN_REMOVE,
      uuid,
    });

    saveSettings();
  };
};

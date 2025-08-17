import { debounce } from 'lodash';

import api from '../api';

import { showAlertForError } from './alerts';

export const SETTING_CHANGE = 'SETTING_CHANGE';
export const SETTING_SAVE   = 'SETTING_SAVE';

export function changeSetting(path, value) {
  return dispatch => {
    dispatch({
      type: SETTING_CHANGE,
      path,
      value,
    });

    dispatch(saveSettings());
  };
}

const debouncedSave = debounce((dispatch, getState) => {
  if (getState().getIn(['settings', 'saved']) || !getState().getIn(['meta', 'me'])) {
    return;
  }

  const data = getState().get('settings').filter((_, path) => path !== 'saved').toJS();

  api().put('/api/web/settings', { data })
    .then(() => dispatch({ type: SETTING_SAVE }))
    .catch(error => dispatch(showAlertForError(error)));
}, 2000, { leading: true, trailing: true });

export function saveSettings() {
  return (dispatch, getState) => debouncedSave(dispatch, getState);
}

import api from '../api';
import { debounce } from 'lodash';

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
};

const debouncedSave = debounce((dispatch, getState) => {
  if (getState().settings.get('saved')) {
    return;
  }

  const data = getState().settings.filter((_, path) => path !== 'saved').toJS();

  api(getState).put('/api/web/settings', { data }).then(() => dispatch({ type: SETTING_SAVE }));
}, 5000, { trailing: true });

export function saveSettings() {
  return (dispatch, getState) => debouncedSave(dispatch, getState);
};

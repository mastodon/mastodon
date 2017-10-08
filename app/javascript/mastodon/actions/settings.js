import axios from 'axios';
import { debounce } from 'lodash';

export const SETTING_CHANGE = 'SETTING_CHANGE';
export const SETTING_SAVE   = 'SETTING_SAVE';

export function changeSetting(key, value) {
  return dispatch => {
    dispatch({
      type: SETTING_CHANGE,
      key,
      value,
    });

    dispatch(saveSettings());
  };
};

const debouncedSave = debounce((dispatch, getState) => {
  if (getState().getIn(['settings', 'saved'])) {
    return;
  }

  const data = getState().get('settings').filter((_, key) => key !== 'saved').toJS();

  axios.put('/api/web/settings', { data }).then(() => dispatch({ type: SETTING_SAVE }));
}, 5000, { trailing: true });

export function saveSettings() {
  return (dispatch, getState) => debouncedSave(dispatch, getState);
};

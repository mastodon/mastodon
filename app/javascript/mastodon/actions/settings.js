import axios from 'axios';

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

export function saveSettings() {
  return (dispatch, getState) => {
    const data = getState().get('settings').filter((_, key) => key !== 'saved').toJS();

    axios.put('/api/web/settings', { data }).then(() => dispatch({ type: SETTING_SAVE }));
  };
};

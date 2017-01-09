import axios from 'axios';

export const SETTING_CHANGE = 'SETTING_CHANGE';

export function changeSetting(key, value) {
  return (dispatch, getState) => {
    dispatch({
      type: SETTING_CHANGE,
      key,
      value
    });

    axios.put('/api/web/settings', {
      data: getState().get('settings').toJS()
    });
  };
};

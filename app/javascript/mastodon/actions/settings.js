import axios from 'axios';

export const SETTING_CHANGE = 'SETTING_CHANGE';

export function changeSetting(key, value) {
  return {
    type: SETTING_CHANGE,
    key,
    value,
  };
};

export function saveSettings() {
  return (_, getState) => {
    axios.put('/api/web/settings', {
      data: getState().get('settings').toJS(),
    });
  };
};

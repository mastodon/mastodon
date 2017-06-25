export const LOCAL_SETTING_CHANGE = 'LOCAL_SETTING_CHANGE';

export function changeLocalSetting(key, value) {
  return dispatch => {
    dispatch({
      type: LOCAL_SETTING_CHANGE,
      key,
      value,
    });

    dispatch(saveLocalSettings());
  };
};

export function saveLocalSettings() {
  return (_, getState) => {
    const localSettings = getState().get('localSettings').toJS();
    localStorage.setItem('mastodon-settings', JSON.stringify(localSettings));
  };
};

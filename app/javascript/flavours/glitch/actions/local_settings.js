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

//  __TODO :__
//  Right now `saveLocalSettings()` doesn't keep track of which user
//  is currently signed in, but it might be better to give each user
//  their *own* local settings.
export function saveLocalSettings() {
  return (_, getState) => {
    const localSettings = getState().get('local_settings').toJS();
    localStorage.setItem('mastodon-settings', JSON.stringify(localSettings));
  };
};

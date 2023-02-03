import { expandSpoilers, disableSwiping } from 'flavours/glitch/initial_state';
import { openModal } from './modal';

export const LOCAL_SETTING_CHANGE = 'LOCAL_SETTING_CHANGE';
export const LOCAL_SETTING_DELETE = 'LOCAL_SETTING_DELETE';

export function checkDeprecatedLocalSettings() {
  return (dispatch, getState) => {
    const local_auto_unfold = getState().getIn(['local_settings', 'content_warnings', 'auto_unfold']);
    const local_swipe_to_change_columns = getState().getIn(['local_settings', 'swipe_to_change_columns']);
    let changed_settings = [];

    if (local_auto_unfold !== null && local_auto_unfold !== undefined) {
      if (local_auto_unfold === expandSpoilers) {
        dispatch(deleteLocalSetting(['content_warnings', 'auto_unfold']));
      } else {
        changed_settings.push('user_setting_expand_spoilers');
      }
    }

    if (local_swipe_to_change_columns !== null && local_swipe_to_change_columns !== undefined) {
      if (local_swipe_to_change_columns === !disableSwiping) {
        dispatch(deleteLocalSetting(['swipe_to_change_columns']));
      } else {
        changed_settings.push('user_setting_disable_swiping');
      }
    }

    if (changed_settings.length > 0) {
      dispatch(openModal('DEPRECATED_SETTINGS', {
        settings: changed_settings,
        onConfirm: () => dispatch(clearDeprecatedLocalSettings()),
      }));
    }
  };
}

export function clearDeprecatedLocalSettings() {
  return (dispatch) => {
    dispatch(deleteLocalSetting(['content_warnings', 'auto_unfold']));
    dispatch(deleteLocalSetting(['swipe_to_change_columns']));
  };
}

export function changeLocalSetting(key, value) {
  return dispatch => {
    dispatch({
      type: LOCAL_SETTING_CHANGE,
      key,
      value,
    });

    dispatch(saveLocalSettings());
  };
}

export function deleteLocalSetting(key) {
  return dispatch => {
    dispatch({
      type: LOCAL_SETTING_DELETE,
      key,
    });

    dispatch(saveLocalSettings());
  };
}

//  __TODO :__
//  Right now `saveLocalSettings()` doesn't keep track of which user
//  is currently signed in, but it might be better to give each user
//  their *own* local settings.
export function saveLocalSettings() {
  return (_, getState) => {
    const localSettings = getState().get('local_settings').toJS();
    localStorage.setItem('mastodon-settings', JSON.stringify(localSettings));
  };
}

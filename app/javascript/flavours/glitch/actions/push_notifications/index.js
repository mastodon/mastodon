import {
  SET_BROWSER_SUPPORT,
  SET_SUBSCRIPTION,
  CLEAR_SUBSCRIPTION,
  SET_ALERTS,
  setAlerts,
} from './setter';
import { register, saveSettings } from './registerer';

export {
  SET_BROWSER_SUPPORT,
  SET_SUBSCRIPTION,
  CLEAR_SUBSCRIPTION,
  SET_ALERTS,
  register,
};

export function changeAlerts(key, value) {
  return dispatch => {
    dispatch(setAlerts(key, value));
    dispatch(saveSettings());
  };
}

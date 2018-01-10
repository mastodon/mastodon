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

export function changeAlerts(path, value) {
  return dispatch => {
    dispatch(setAlerts(path, value));
    dispatch(saveSettings());
  };
}

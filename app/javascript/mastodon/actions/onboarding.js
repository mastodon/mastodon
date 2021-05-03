import { changeSetting, saveSettings } from './settings';
import { requestBrowserPermission } from './notifications';

export const INTRODUCTION_VERSION = 20181216044202;

export const closeOnboarding = () => dispatch => {
  dispatch(changeSetting(['introductionVersion'], INTRODUCTION_VERSION));
  dispatch(saveSettings());

  dispatch(requestBrowserPermission((permission) => {
    if (permission === 'granted') {
      dispatch(changeSetting(['notifications', 'alerts', 'follow'], true));
      dispatch(changeSetting(['notifications', 'alerts', 'favourite'], true));
      dispatch(changeSetting(['notifications', 'alerts', 'reblog'], true));
      dispatch(changeSetting(['notifications', 'alerts', 'mention'], true));
      dispatch(changeSetting(['notifications', 'alerts', 'poll'], true));
      dispatch(changeSetting(['notifications', 'alerts', 'status'], true));
      dispatch(saveSettings());
    }
  }));
};

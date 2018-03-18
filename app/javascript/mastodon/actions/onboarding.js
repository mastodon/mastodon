import { openModal } from './modal';
import { changeSetting, saveSettings } from './settings';

export function showOnboardingOnce() {
  return (dispatch, getState) => {
    const alreadySeen = getState().settings.get('onboarded');

    if (!alreadySeen) {
      dispatch(openModal('ONBOARDING'));
      dispatch(changeSetting(['onboarded'], true));
      dispatch(saveSettings());
    }
  };
};

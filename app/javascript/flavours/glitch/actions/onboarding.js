import { openModal } from './modal';
import { changeSetting, saveSettings } from './settings';

export function showOnboardingOnce() {
  return (dispatch, getState) => {
    const alreadySeen = getState().getIn(['settings', 'onboarded']);

    if (!alreadySeen) {
      dispatch(openModal({
        modalType: 'ONBOARDING',
      }));
      dispatch(changeSetting(['onboarded'], true));
      dispatch(saveSettings());
    }
  };
}

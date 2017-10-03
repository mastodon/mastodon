import { openModal } from './modal';
import { changeSetting, saveSettings } from './settings';
import { isMobile } from '../is_mobile';
import { getLocale } from '../locales';

export function showOnboardingOnce() {
  return (dispatch, getState) => {
    const alreadySeen = getState().getIn(['settings', 'onboarded']);
    const isJa = getLocale().localeData[0].locale.indexOf('ja') !== -1;

    if (!alreadySeen) {
      if (!isMobile(window.innerWidth) && isJa) {
        dispatch(openTutorial());
      } else {
        dispatch(openModal('ONBOARDING'));
      }
      dispatch(changeSetting(['onboarded'], true));
      dispatch(saveSettings());
    }
  };
};

export const TUTORIAL_OPEN = 'TUTORIAL_OPEN';
export const TUTORIAL_CLOSE = 'TUTORIAL_CLOSE';

export function openTutorial() {
  return {
    type: TUTORIAL_OPEN,
  };
};

export function closeTutorial() {
  return {
    type: TUTORIAL_CLOSE,
  };
};

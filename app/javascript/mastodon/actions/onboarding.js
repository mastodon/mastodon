import { openModal } from './modal';
import { changeSetting, saveSettings } from './settings';
import { openTutorial } from './tutorial';
import { isMobile } from '../is_mobile';
import { getLocale } from '../locales';

export function showOnboardingOnce() {
  return (dispatch, getState) => {
    const alreadySeen = getState().getIn(['settings', 'onboarded']);
    const isJa = getLocale().localeData[0].locale === 'ja';

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

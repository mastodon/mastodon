import { saveSettings } from './settings';

export const LANGUAGE_USE = 'LANGUAGE_USE';

export const useLanguage = language => dispatch => {
  dispatch({
    type: LANGUAGE_USE,
    language,
  });

  dispatch(saveSettings());
};

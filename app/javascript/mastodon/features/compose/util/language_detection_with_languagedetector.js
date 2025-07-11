import { debounce } from 'lodash';

import { countLetters } from './language_detection';
import { urlRegex } from './url_regex';

const guessLanguage = async (text) => {
  text = text
    .replace(urlRegex, '')
    .replace(/(^|[^/\w])@(([a-z0-9_]+)@[a-z0-9.-]+[a-z0-9]+)/ig, '');

  if (countLetters(text) > 5) {
    try {
      const languageDetector = await self.LanguageDetector.create();
      let {detectedLanguage, confidence} = (await languageDetector.detect(text))[0];
      if (confidence > 0.8) {
        detectedLanguage = detectedLanguage.split('-')[0];
        return detectedLanguage;
      }
    } catch {
      return '';
    }
  }

  return '';
};

const debouncedGuess = (() => {
  let resolver = null;
  let rejecter = null;

  const debounced = debounce(async (text) => {
    try {
      const result = await guessLanguage(text);
      if (resolver) {
        resolver(result);
        resolver = null;
      }
    } catch {
      rejecter('');
    }
  }, 500, { maxWait: 1500, leading: true, trailing: true });

  return (text) => new Promise((resolve, reject) => {
    resolver = resolve;
    rejecter = reject;
    debounced(text);
  });
})();

export { debouncedGuess };

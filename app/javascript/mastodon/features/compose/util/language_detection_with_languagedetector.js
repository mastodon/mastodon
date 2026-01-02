import { debounce } from 'lodash';

import { urlRegex } from './url_regex';

const guessLanguage = async (text) => {
  text = text
    .replace(urlRegex, '')
    .replace(/(^|[^/\w])@(([a-z0-9_]+)@[a-z0-9.-]+[a-z0-9]+)/ig, '');

  try {
    const languageDetector = await globalThis.LanguageDetector.create();
    let {detectedLanguage, confidence} = (await languageDetector.detect(text))[0];
    if (confidence > 0.8) {
      detectedLanguage = detectedLanguage.split('-')[0];
      return detectedLanguage;
    }
  } catch {
    return '';
  }

  return '';
};

const debouncedGuess = (() => {
  let resolver = null;

  const debounced = debounce((text) => {
    const result = guessLanguage(text);
    if (resolver) {
      resolver(result);
      resolver = null;
    }
  }, 500, { maxWait: 1500, leading: true, trailing: true });

  return (text) => new Promise((resolve) => {
    resolver = resolve;
    debounced(text);
  });
})();

export { debouncedGuess };

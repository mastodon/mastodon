import lande from 'lande';
import { debounce } from 'lodash';

import { countLetters, ISO_639_MAP } from './language_detection';
import { urlRegex } from './url_regex';

const guessLanguage = (text) => {
  text = text
    .replace(urlRegex, '')
    .replace(/(^|[^/\w])@(([a-z0-9_]+)@[a-z0-9.-]+[a-z0-9]+)/ig, '');

  if (countLetters(text) > 20) {
    const [lang, confidence] = lande(text)[0];
    if (confidence > 0.8)
      return ISO_639_MAP[lang];
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

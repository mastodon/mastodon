import { createSelector } from '@reduxjs/toolkit';
import { Map as ImmutableMap } from 'immutable';
import { connect } from 'react-redux';

import lande from 'lande';
import { debounce } from 'lodash';

import { changeComposeLanguage } from 'mastodon/actions/compose';

import LanguageDropdown from '../components/language_dropdown';
import { urlRegex } from '../util/url_regex';

const getFrequentlyUsedLanguages = createSelector([
  state => state.getIn(['settings', 'frequentlyUsedLanguages'], ImmutableMap()),
], languageCounters => (
  languageCounters.keySeq()
    .sort((a, b) => languageCounters.get(a) - languageCounters.get(b))
    .reverse()
    .toArray()
));

const ISO_639_MAP = {
  afr: 'af', // Afrikaans
  ara: 'ar', // Arabic
  aze: 'az', // Azerbaijani
  bel: 'be', // Belarusian
  ben: 'bn', // Bengali
  bul: 'bg', // Bulgarian
  cat: 'ca', // Catalan
  ces: 'cs', // Czech
  ckb: 'ku', // Kurdish
  cmn: 'zh', // Mandarin
  dan: 'da', // Danish
  deu: 'de', // German
  ell: 'el', // Greek
  eng: 'en', // English
  est: 'et', // Estonian
  eus: 'eu', // Basque
  fin: 'fi', // Finnish
  fra: 'fr', // French
  hau: 'ha', // Hausa
  heb: 'he', // Hebrew
  hin: 'hi', // Hindi
  hrv: 'hr', // Croatian
  hun: 'hu', // Hungarian
  hye: 'hy', // Armenian
  ind: 'id', // Indonesian
  isl: 'is', // Icelandic
  ita: 'it', // Italian
  jpn: 'ja', // Japanese
  kat: 'ka', // Georgian
  kaz: 'kk', // Kazakh
  kor: 'ko', // Korean
  lit: 'lt', // Lithuanian
  mar: 'mr', // Marathi
  mkd: 'mk', // Macedonian
  nld: 'nl', // Dutch
  nob: 'no', // Norwegian
  pes: 'fa', // Persian
  pol: 'pl', // Polish
  por: 'pt', // Portuguese
  ron: 'ro', // Romanian
  run: 'rn', // Rundi
  rus: 'ru', // Russian
  slk: 'sk', // Slovak
  spa: 'es', // Spanish
  srp: 'sr', // Serbian
  swe: 'sv', // Swedish
  tgl: 'tl', // Tagalog
  tur: 'tr', // Turkish
  ukr: 'uk', // Ukrainian
  vie: 'vi', // Vietnamese
};

const debouncedLande = debounce((text) => {
  text = text
    .replace(urlRegex, '')
    .replace(/(^|[^/\w])@(([a-z0-9_]+)@[a-z0-9.-]+[a-z0-9]+)/ig, '');

  if (text.length <= 20)
    return undefined;

  return lande(text);
}, 500, { trailing: true });

const detectedLanguage = createSelector([
  state => state.getIn(['compose', 'text']),
], text => {
  if (text.length > 20) {
    const guesses = debouncedLande(text);
    if (!guesses)
      return '';

    const [lang, confidence] = guesses[0];

    if (confidence > 0.8) {
      return ISO_639_MAP[lang];
    }
  }

  return '';
});

const mapStateToProps = state => ({
  frequentlyUsedLanguages: getFrequentlyUsedLanguages(state),
  value: state.getIn(['compose', 'language']),
  guess: detectedLanguage(state),
});

const mapDispatchToProps = dispatch => ({

  onChange (value) {
    dispatch(changeComposeLanguage(value));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(LanguageDropdown);

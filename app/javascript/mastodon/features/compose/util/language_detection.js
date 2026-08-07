const languageDetectorInGlobalThis = 'LanguageDetector' in globalThis;
let languageDetectorSupportedAndReady = languageDetectorInGlobalThis && await globalThis.LanguageDetector.availability() === 'available';

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

const countLetters = (text) => {
  const segmenter = new Intl.Segmenter('und', { granularity: 'grapheme' })
  const letters = [...segmenter.segment(text)]
  return letters.length
};

let module;
// If the API is supported, but the model not loaded yet…
if (languageDetectorInGlobalThis) {
  if (!languageDetectorSupportedAndReady) {
    // …trigger the model download
    globalThis.LanguageDetector.create();
  }
  module = await import('./language_detection_with_languagedetector');
} else {
  module = await import('./language_detection_with_lande');
}
const debouncedGuess = module.debouncedGuess;

export { debouncedGuess, countLetters, ISO_639_MAP };

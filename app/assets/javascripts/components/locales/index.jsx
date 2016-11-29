import en from './en';
import de from './de';
import es from './es';
import hu from './hu';
import fr from './fr';
import pt from './pt';

const locales = {
  en,
  de,
  es,
  hu,
  fr,
  pt
};

export default function getMessagesForLocale (locale) {
  return locales[locale];
};

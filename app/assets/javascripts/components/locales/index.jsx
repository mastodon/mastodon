import en from './en';
import de from './de';
import es from './es';
import fr from './fr';

const locales = {
  en,
  de,
  es,
  fr
};

export default function getMessagesForLocale (locale) {
  return locales[locale];
};

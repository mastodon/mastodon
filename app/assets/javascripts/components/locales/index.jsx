import en from './en';
import de from './de';
import es from './es';

const locales = {
  en,
  de,
  es
};

export default function getMessagesForLocale (locale) {
  return locales[locale];
};

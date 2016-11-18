import en from './en';
import de from './de';

const locales = {
  en,
  de
};

export default function getMessagesForLocale (locale) {
  return locales[locale];
};

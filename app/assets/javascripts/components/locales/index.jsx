import en from './en';
import de from './de';
import es from './es';
import hu from './hu';
import fr from './fr';
import pt from './pt';
import uk from './uk';
import fi from './fi';
import eo from './eo';
import ru from './ru';


const locales = {
  en,
  de,
  es,
  hu,
  fr,
  pt,
  uk,
  fi,
  eo,
  ru

};

export default function getMessagesForLocale (locale) {
  return locales[locale];
};

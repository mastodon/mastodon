import en from './en';
import de from './de';
import es from './es';
import hu from './hu';
import fr from './fr';
import nl from './nl';
import pt from './pt';
import uk from './uk';
import fi from './fi';

const locales = {
  en,
  de,
  es,
  hu,
  fr,
  nl,
  pt,
  uk,
  fi
};

export default function getMessagesForLocale (locale) {
  return locales[locale];
};

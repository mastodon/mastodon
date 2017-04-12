import en from './en';
import de from './de';
import es from './es';
import hu from './hu';
import fr from './fr';
import no from './no';
import pt from './pt';
import uk from './uk';
import fi from './fi';
import eo from './eo';
import ru from './ru';
import ja from './ja';
import zh_hk from './zh-hk';


const locales = {
  en,
  de,
  es,
  hu,
  fr,
  no,
  pt,
  uk,
  fi,
  eo,
  ru,
  ja,
  'zh-HK': zh_hk,
};

export default function getMessagesForLocale (locale) {
  return locales[locale];
};

import en from './en';
import de from './de';
import es from './es';
import hr from './hr';
import hu from './hu';
import fr from './fr';
import nl from './nl';
import no from './no';
import pt from './pt';
import pt_br from './pt-br';
import uk from './uk';
import fi from './fi';
import eo from './eo';
import ru from './ru';
import ja from './ja';
import zh_hk from './zh-hk';
import bg from './bg';

const locales = {
  en,
  de,
  es,
  hr,
  hu,
  fr,
  nl,
  no,
  pt,
  'pt-BR': pt_br,
  uk,
  fi,
  eo,
  ru,
  ja,
  'zh-HK': zh_hk,
  bg,
};

export default function getMessagesForLocale (locale) {
  return locales[locale];
};

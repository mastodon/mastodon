import ar from './ar.json';
import en from './en.json';
import ca from './ca.json';
import de from './de.json';
import es from './es.json';
import fa from './fa.json';
import he from './he.json';
import hr from './hr.json';
import hu from './hu.json';
import io from './io.json';
import it from './it.json';
import fr from './fr.json';
import nl from './nl.json';
import no from './no.json';
import oc from './oc.json';
import pt from './pt.json';
import pt_br from './pt-BR.json';
import uk from './uk.json';
import fi from './fi.json';
import eo from './eo.json';
import ru from './ru.json';
import ja from './ja.json';
import zh_hk from './zh-HK.json';
import zh_cn from './zh-CN.json';
import bg from './bg.json';
import id from './id.json';
import tr from './tr.json';

const locales = {
  ar,
  en,
  ca,
  de,
  es,
  fa,
  he,
  hr,
  hu,
  io,
  it,
  fr,
  nl,
  no,
  oc,
  pt,
  'pt-BR': pt_br,
  uk,
  fi,
  eo,
  ru,
  ja,
  'zh-HK': zh_hk,
  'zh-CN': zh_cn,
  bg,
  id,
  tr,
};

export default function getMessagesForLocale(locale) {
  return locales[locale];
};

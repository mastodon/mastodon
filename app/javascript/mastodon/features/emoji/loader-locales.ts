import type { Locale } from 'emojibase';
import bnUrl from 'emojibase-data/bn/compact.json?url';
import daUrl from 'emojibase-data/da/compact.json?url';
import deUrl from 'emojibase-data/de/compact.json?url';
import enUrl from 'emojibase-data/en/compact.json?url';
import enGbUrl from 'emojibase-data/en-gb/compact.json?url';
import esUrl from 'emojibase-data/es/compact.json?url';
import esMxUrl from 'emojibase-data/es-mx/compact.json?url';
import etUrl from 'emojibase-data/et/compact.json?url';
import fiUrl from 'emojibase-data/fi/compact.json?url';
import frUrl from 'emojibase-data/fr/compact.json?url';
import hiUrl from 'emojibase-data/hi/compact.json?url';
import huUrl from 'emojibase-data/hu/compact.json?url';
import itUrl from 'emojibase-data/it/compact.json?url';
import jaUrl from 'emojibase-data/ja/compact.json?url';
import koUrl from 'emojibase-data/ko/compact.json?url';
import ltUrl from 'emojibase-data/lt/compact.json?url';
import msUrl from 'emojibase-data/ms/compact.json?url';
import nbUrl from 'emojibase-data/nb/compact.json?url';
import nlUrl from 'emojibase-data/nl/compact.json?url';
import plUrl from 'emojibase-data/pl/compact.json?url';
import ptUrl from 'emojibase-data/pt/compact.json?url';
import ruUrl from 'emojibase-data/ru/compact.json?url';
import svUrl from 'emojibase-data/sv/compact.json?url';
import thUrl from 'emojibase-data/th/compact.json?url';
import ukUrl from 'emojibase-data/uk/compact.json?url';
import viUrl from 'emojibase-data/vi/compact.json?url';
import zhUrl from 'emojibase-data/zh/compact.json?url';
import zhHantUrl from 'emojibase-data/zh-hant/compact.json?url';

const localeToUrlMap: Record<Locale, string> = {
  bn: bnUrl,
  de: deUrl,
  en: enUrl,
  'en-gb': enGbUrl,
  es: esUrl,
  'es-mx': esMxUrl,
  fr: frUrl,
  hu: huUrl,
  it: itUrl,
  ja: jaUrl,
  ko: koUrl,
  nl: nlUrl,
  da: daUrl,
  et: etUrl,
  fi: fiUrl,
  hi: hiUrl,
  lt: ltUrl,
  ms: msUrl,
  nb: nbUrl,
  pl: plUrl,
  pt: ptUrl,
  ru: ruUrl,
  sv: svUrl,
  th: thUrl,
  uk: ukUrl,
  vi: viUrl,
  zh: zhUrl,
  'zh-hant': zhHantUrl,
};

export function localeToUrl(locale: Locale) {
  return localeToUrlMap[locale];
}

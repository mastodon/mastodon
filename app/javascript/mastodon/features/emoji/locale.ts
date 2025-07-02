import type { CompactEmoji, FlatCompactEmoji, Locale } from 'emojibase';
import { flattenEmojiData, SUPPORTED_LOCALES } from 'emojibase';

export type LocaleOrCustom = Locale | 'custom';

// Simple cache. This will be replaced with an IndexedDB cache in the future.
const localeCache = new Map<Locale, Map<string, FlatCompactEmoji>>();

export async function unicodeToLocaleLabel(
  unicodeHex: string,
  localeString: string,
) {
  const locale = toSupportedLocale(localeString);
  let hexMap = localeCache.get(locale);
  if (!hexMap) {
    const emojis = await loadLocaleEmojis(locale);
    hexMap = new Map(emojis.map((emoji) => [emoji.hexcode, emoji]));
    localeCache.set(locale, hexMap);
  }

  const label = hexMap.get(unicodeHex)?.label;
  if (!label) {
    throw new Error(
      `Label for unicode hex ${unicodeHex} not found in locale ${locale}`,
    );
  }
  return label;
}

export async function loadLocaleEmojis(locale: Locale) {
  const { default: localeEmoji } = ((await import(
    `../../../../../node_modules/emojibase-data/${locale}/compact.json`
  )) ?? { default: [] }) as { default: CompactEmoji[] };
  if (!Array.isArray(localeEmoji)) {
    throw new Error(`Locale data for ${locale} not found`);
  }
  return flattenEmojiData(localeEmoji) as FlatCompactEmoji[];
}

export function toSupportedLocale(localeBase: string): Locale {
  const locale = localeBase.toLowerCase();
  if (isSupportedLocale(locale)) {
    return locale;
  }
  return 'en'; // Default to English if unsupported
}

export function toSupportedLocaleOrCustom(locale: string): LocaleOrCustom {
  if (locale.toLowerCase() === 'custom') {
    return 'custom';
  }
  return toSupportedLocale(locale);
}

function isSupportedLocale(locale: string): locale is Locale {
  return SUPPORTED_LOCALES.includes(locale.toLowerCase() as Locale);
}

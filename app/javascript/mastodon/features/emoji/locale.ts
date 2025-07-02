import type { CompactEmoji, Locale } from 'emojibase';
import { flattenEmojiData, SUPPORTED_LOCALES } from 'emojibase';

// Simple cache. This will be replaced with an IndexedDB cache in the future.
const localeCache = new Map<Locale, Map<string, CompactEmoji>>();

export async function unicodeToLocaleLabel(
  unicodeHex: string,
  localeString: string,
) {
  const locale = toSupportedLocale(localeString);
  let hexMap = localeCache.get(locale);
  if (!hexMap) {
    hexMap = await loadLocaleLabels(locale);
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

async function loadLocaleLabels(
  locale: Locale,
): Promise<Map<string, CompactEmoji>> {
  const { default: localeEmoji } = ((await import(
    `emojibase-data/${locale}/compact.json`
  )) ?? { default: [] }) as { default: CompactEmoji[] };
  if (!Array.isArray(localeEmoji)) {
    throw new Error(`Locale data for ${locale} not found`);
  }
  const hexMapEntries = flattenEmojiData(localeEmoji).map(
    (emoji) => [emoji.hexcode, emoji] satisfies [string, CompactEmoji],
  );
  return new Map(hexMapEntries);
}

export function toSupportedLocale(locale: string): Locale {
  if (isSupportedLocale(locale)) {
    return locale;
  }
  return 'en'; // Default to English if unsupported
}

function isSupportedLocale(locale: string): locale is Locale {
  return SUPPORTED_LOCALES.includes(locale as Locale);
}

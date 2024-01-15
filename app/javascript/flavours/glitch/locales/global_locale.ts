import { isDevelopment } from 'flavours/glitch/utils/environment';

export interface LocaleData {
  locale: string;
  messages: Record<string, string>;
}

let loadedLocale: LocaleData | undefined;

export function setLocale(locale: LocaleData) {
  loadedLocale = locale;
}

export function getLocale(): LocaleData {
  if (!loadedLocale) {
    if (isDevelopment()) {
      throw new Error('getLocale() called before any locale has been set');
    } else {
      return { locale: 'unknown', messages: {} };
    }
  }

  return loadedLocale;
}

export function isLocaleLoaded() {
  return !!loadedLocale;
}

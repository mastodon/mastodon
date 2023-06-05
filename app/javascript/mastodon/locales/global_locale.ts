export interface LocaleData {
  locale: string;
  messages: Record<string, string>;
}

let loadedLocale: LocaleData;

export function setLocale(locale: LocaleData) {
  loadedLocale = locale;
}

export function getLocale() {
  if (!loadedLocale && process.env.NODE_ENV === 'development') {
    throw new Error('getLocale() called before any locale has been set');
  }

  return loadedLocale;
}

export function isLocaleLoaded() {
  return !!loadedLocale;
}

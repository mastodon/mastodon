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
    if (process.env.NODE_ENV === 'development') {
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

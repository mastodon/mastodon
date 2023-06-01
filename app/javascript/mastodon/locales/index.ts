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

export function onProviderError(error: unknown) {
  // Silent the error, like upstream does
  if (process.env.NODE_ENV === 'production') return;

  // This browser does not advertise Intl support for this locale, we only print a warning
  // As-per the spec, the browser should select the best matching locale
  if (
    error &&
    typeof error === 'object' &&
    error instanceof Error &&
    error.message.match('MISSING_DATA')
  ) {
    console.warn(error.message);
  }

  console.error(error);
}

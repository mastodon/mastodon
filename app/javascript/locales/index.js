let theLocale;

export function setLocale(locale) {
  theLocale = locale;
}

export function getLocale() {
  return theLocale;
}

export function onProviderError(error) {
  // Silent the error, like upstream does
  if(process.env.NODE_ENV === 'production') return;

  // This browser does not advertise Intl support for this locale, we only print a warning
  // As-per the spec, the browser should select the best matching locale
  if(typeof error === "object" && error.message.match("MISSING_DATA")) {
    console.warn(error.message);
  }

  console.error(error);
}

// import { shouldPolyfill as shouldPolyfillCanonicalLocales } from '@formatjs/intl-getcanonicallocales/should-polyfill';
// import { shouldPolyfill as shouldPolyfillLocale } from '@formatjs/intl-locale/should-polyfill';
import { shouldPolyfill as shoudPolyfillPluralRules } from '@formatjs/intl-pluralrules/should-polyfill';
// import { shouldPolyfill as shouldPolyfillNumberFormat } from '@formatjs/intl-numberformat/should-polyfill';
// import { shouldPolyfill as shouldPolyfillIntlDateTimeFormat } from '@formatjs/intl-datetimeformat/should-polyfill';
// import { shouldPolyfill as shouldPolyfillIntlRelativeTimeFormat } from '@formatjs/intl-relativetimeformat/should-polyfill';

// async function loadGetCanonicalLocalesPolyfill() {
//   // This platform already supports Intl.getCanonicalLocales
//   if (shouldPolyfillCanonicalLocales()) {
//     await import('@formatjs/intl-getcanonicallocales/polyfill');
//   }
// }

// async function loadLocalePolyfill() {
//   // This platform already supports Intl.Locale
//   if (shouldPolyfillLocale()) {
//     await import('@formatjs/intl-locale/polyfill');
//   }
// }

// async function loadIntlNumberFormatPolyfill(locale: string) {
//   const unsupportedLocale = shouldPolyfillNumberFormat(locale);
//   // This locale is supported
//   if (!unsupportedLocale) {
//     return;
//   }
//   // Load the polyfill 1st BEFORE loading data
//   await import('@formatjs/intl-numberformat/polyfill-force');
//   await import(`@formatjs/intl-numberformat/locale-data/${unsupportedLocale}`);
// }

// async function loadIntlDateTimeFormatPolyfill(locale: string) {
//   const unsupportedLocale = shouldPolyfillIntlDateTimeFormat(locale);
//   // This locale is supported
//   if (!unsupportedLocale) {
//     return;
//   }
//   // Load the polyfill 1st BEFORE loading data
//   await import('@formatjs/intl-datetimeformat/polyfill-force');

//   // Parallelize CLDR data loading
//   const dataPolyfills = [
//     import('@formatjs/intl-datetimeformat/add-all-tz'),
//     import(`@formatjs/intl-datetimeformat/locale-data/${unsupportedLocale}`),
//   ];
//   await Promise.all(dataPolyfills);
// }

async function loadIntlPluralRulesPolyfills(locale: string) {
  const unsupportedLocale = shoudPolyfillPluralRules(locale);
  // This locale is supported
  if (!unsupportedLocale) {
    return;
  }
  // Load the polyfill 1st BEFORE loading data
  await import(
    /* webpackChunkName: "i18n-pluralrules-polyfill" */ '@formatjs/intl-pluralrules/polyfill-force'
  );
  await import(
    /* webpackChunkName: "i18n-pluralrules-polyfill-[request]" */ `@formatjs/intl-pluralrules/locale-data/${unsupportedLocale}`
  );
}

// async function loadIntlRelativeTimeFormatPolyfill(locale: string) {
//   const unsupportedLocale = shouldPolyfillIntlRelativeTimeFormat(locale);
//   // This locale is supported
//   if (!unsupportedLocale) {
//     return;
//   }
//   // Load the polyfill 1st BEFORE loading data
//   await import(
//     /* webpackChunkName: "i18n-relativetimeformat-polyfill" */
//     '@formatjs/intl-relativetimeformat/polyfill-force'
//   );
//   await import(
//     /* webpackChunkName: "i18n-relativetimeformat-polyfill-[request]" */
//     `@formatjs/intl-relativetimeformat/locale-data/${unsupportedLocale}`
//   );
// }

export async function loadIntlPolyfills() {
  const locale = document.querySelector('html')?.lang || 'en';

  // order is important here

  // Supported in IE11 and most other browsers, not useful
  // await loadGetCanonicalLocalesPolyfill()

  // Supported in IE11 and most other browsers, not useful
  // await loadLocalePolyfill()

  // Supported in IE11 and most other browsers, not useful
  // await loadIntlNumberFormatPolyfill(locale)

  // Supported in IE11 and most other browsers, not useful
  // await loadIntlDateTimeFormatPolyfill(locale)

  // Supported from Safari 13+, may still be useful
  await loadIntlPluralRulesPolyfills(locale);

  // This is not used yet in the codebase yet
  // Supported from Safari 14+
  // await loadIntlRelativeTimeFormatPolyfill(locale);
}

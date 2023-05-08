import { setLocale } from "./locales";

export async function loadLocale() {
  const locale = document.querySelector('html').lang || 'en';

  const localeData = await import(
    /* webpackMode: "lazy" */
    /* webpackChunkName: "locale/[request]" */
    /* webpackInclude: /\.json$/ */
    /* webpackExclude: /(defaultMessages.json|whitelist_.+)$/ */
    /* webpackPreload: true */
    `mastodon/locales/${locale}.json`);

  setLocale({ messages: localeData });
}

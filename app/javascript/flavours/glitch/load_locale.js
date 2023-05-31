import { setLocale } from 'locales';

export async function loadLocale() {
  const locale = document.querySelector('html').lang || 'en';

  const upstreamLocaleData = await import(
    /* webpackMode: "lazy" */
    /* webpackChunkName: "locales/vanilla/[request]" */
    /* webpackInclude: /\.json$/ */
    /* webpackPreload: true */
    `mastodon/locales/${locale}.json`);

  const localeData = await import(
    /* webpackMode: "lazy" */
    /* webpackChunkName: "locales/glitch/[request]" */
    /* webpackInclude: /\.json$/ */
    /* webpackPreload: true */
    `flavours/glitch/locales/${locale}.json`);

  setLocale({ messages: {...upstreamLocaleData, ...localeData} });
}

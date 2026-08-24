import { defineConfig } from '@eloqnt/cli';

export default defineConfig({
  messages: {
    path: './app/javascript/mastodon/locales/{code}',
    locales: 'infer',
    sourceLocale: 'en',
    format: 'json',
    // Two files aren't named after the locale they hold: `ry` is Rusyn and
    // `tai` is Taiwanese Hokkien in Tâi-lô romanization, both spelled the way
    // Crowdin's `%two_letters_code%` writes them.
    codes: {
      rue: 'ry',
      'nan-Latn-TW': 'tai',
    },
  },
});

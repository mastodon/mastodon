/* This plugin provides the `virtual:mastodon-sw-locales` import
   which exports translations for every locales, but only with the
   keys defined below.
   This is used by the notifications code in the service-worker, to
   provide localised texts without having to load all the translations
*/

import fs from 'node:fs';
import path from 'node:path';

import { defineMessages } from 'react-intl';

import type { Plugin, ResolvedConfig } from 'vite';

const translations = defineMessages({
  mentioned_you: {
    id: 'notification.mentioned_you',
    defaultMessage: '{name} mentioned you',
  },
});

const CUSTOM_TRANSLATIONS = {
  'notification.mention': translations.mentioned_you.id,
};

const KEEP_KEYS = [
  'notification.favourite',
  'notification.follow',
  'notification.follow_request',
  'notification.mention',
  'notification.reblog',
  'notification.poll',
  'notification.status',
  'notification.update',
  'notification.admin.sign_up',
  'status.show_more',
  'status.reblog',
  'status.favourite',
  'notifications.group',
];

export function MastodonServiceWorkerLocales(): Plugin {
  const virtualModuleId = 'virtual:mastodon-sw-locales';
  const resolvedVirtualModuleId = '\0' + virtualModuleId;

  let config: ResolvedConfig;

  return {
    name: 'mastodon-sw-locales',
    configResolved(resolvedConfig) {
      config = resolvedConfig;
    },
    resolveId(id) {
      if (id === virtualModuleId) {
        return resolvedVirtualModuleId;
      }

      return undefined;
    },
    load(id) {
      if (id === resolvedVirtualModuleId) {
        const filteredLocales: Record<string, Record<string, string>> = {};
        const localesPath = path.resolve(config.root, 'mastodon/locales');

        const filenames = fs.readdirSync(localesPath);

        filenames
          .filter((filename) => /[a-zA-Z-]+\.json$/.exec(filename))
          .forEach((filename) => {
            const content = fs.readFileSync(
              path.resolve(localesPath, filename),
              'utf-8',
            );
            const full = JSON.parse(content) as Record<string, string>;
            const locale = filename.split('.')[0];

            if (!locale)
              throw new Error('Could not parse locale from filename');

            const filteredLocale: Record<string, string> = {};

            Object.entries(full).forEach(([key, value]) => {
              if (KEEP_KEYS.includes(key)) {
                filteredLocale[key] = value;
              }
            });

            Object.entries(CUSTOM_TRANSLATIONS).forEach(([key, value]) => {
              const translation = full[value];
              if (translation) filteredLocale[key] = translation;
            });

            filteredLocales[locale] = filteredLocale;
          });

        return `const locales = ${JSON.stringify(filteredLocales)}; \n export default locales;`;
      }

      return undefined;
    },
  };
}

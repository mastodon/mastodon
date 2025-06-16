/* This plugins handles Mastodon's theme system
 */

import fs from 'node:fs/promises';
import path from 'node:path';

import yaml from 'js-yaml';
import type { Plugin } from 'vite';

export function MastodonThemes(): Plugin {
  const themes: Record<string, string> = {};

  return {
    name: 'mastodon-themes',
    async config(userConfig) {
      if (!userConfig.root || !userConfig.envDir) {
        throw new Error('Unknown project directory');
      }

      const entrypoints: Record<string, string> = {};

      // Get all files mentioned in the themes.yml file.
      const themesFile = path.resolve(userConfig.envDir, 'config/themes.yml');
      if (!themesFile) {
        throw new Error('Themes file must be defined.');
      }
      const themesString = await fs.readFile(themesFile, 'utf8');
      const themesObject = yaml.load(themesString, {
        filename: 'themes.yml',
        schema: yaml.FAILSAFE_SCHEMA,
      });

      if (!themesObject || typeof themes !== 'object') {
        throw new Error('Invalid themes.yml file');
      }

      for (const [themeName, themePath] of Object.entries(themesObject)) {
        if (
          typeof themePath !== 'string' ||
          themePath.split('.').length !== 2 || // Ensure it has exactly one period
          !themePath.endsWith('css')
        ) {
          console.warn(
            `Invalid theme path "${themePath}" in themes.yml, skipping`,
          );
          continue;
        }
        themes[themeName] = themePath;
        entrypoints[`themes/${themeName}`] = path.resolve(
          userConfig.root,
          themePath,
        );
      }

      return {
        build: {
          rollupOptions: {
            input: entrypoints,
          },
        },
      };
    },
    configureServer(server) {
      server.middlewares.use((req, res, next) => {
        const basename = path.basename(req.url ?? '');
        if (
          req.url?.startsWith('/packs-dev/themes/') &&
          Object.hasOwn(themes, basename)
        ) {
          req.url = `${req.url}.css`;
        }
        next();
      });
    },
    async resolveId(source, importer, options) {
      if (!source.startsWith('/themes/')) {
        return null;
      }
      const themeName = source.slice(8).replace(path.extname(source), '');
      const theme = themes[themeName];
      if (typeof theme !== 'string') {
        return null;
      }
      return await this.resolve(
        `/${themes[themeName]}?direct`,
        importer,
        Object.assign({ skipSelf: false, isEntry: true }, options),
      );
    },
  };
}

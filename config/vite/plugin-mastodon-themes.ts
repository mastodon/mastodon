/* This plugins handles Mastodon's theme system
 */

import fs from 'node:fs/promises';
import path from 'node:path';

import yaml from 'js-yaml';
import type { Plugin } from 'vite';

export function MastodonThemes(): Plugin {
  let themesFile: string | null = null;

  const readThemes = async (): Promise<Record<string, string>> => {
    if (!themesFile) {
      throw new Error('Themes file must be defined.');
    }

    // Get all files mentioned in the themes.yml file.
    const themesString = await fs.readFile(themesFile, 'utf8');
    const themes = yaml.load(themesString, {
      filename: 'themes.yml',
      schema: yaml.FAILSAFE_SCHEMA,
    });

    if (!themes || typeof themes !== 'object') {
      throw new Error('Invalid themes.yml file');
    }

    return themes as Record<string, string>;
  };

  return {
    name: 'mastodon-themes',
    async config(userConfig) {
      if (!userConfig.root || !userConfig.envDir) {
        throw new Error('Unknown project directory');
      }

      const entrypoints: Record<string, string> = {};

      // Get all files mentioned in the themes.yml file.
      themesFile = path.resolve(userConfig.envDir, 'config/themes.yml');
      const themes = await readThemes();

      for (const [themeName, themePath] of Object.entries(themes)) {
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
    async resolveId(source, importer, options) {
      if (source.startsWith('/themes/')) {
        const themes = await readThemes();
        const themeName = source.slice(8).replace(path.extname(source), '');

        if (themeName in themes && typeof themes[themeName] === 'string') {
          return await this.resolve(
            `/${themes[themeName]}?direct`,
            importer,
            Object.assign({ skipSelf: false, isEntry: true }, options),
          );
        }
      }
      return await this.resolve(source, importer, options);
    },
  };
}

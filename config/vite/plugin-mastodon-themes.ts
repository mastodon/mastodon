/* This plugins handles Mastodon's theme system
 */

import fs from 'node:fs/promises';
import path from 'node:path';

import yaml from 'js-yaml';
import type { Plugin } from 'vite';

export function MastodonThemes(): Plugin {
  return {
    name: 'mastodon-themes',
    async config(userConfig) {
      if (!userConfig.root || !userConfig.envDir) {
        throw new Error('Unknown project directory');
      }

      const themesFile = path.resolve(userConfig.envDir, 'config/themes.yml');
      const entrypoints: Record<string, string> = {};

      // Get all files mentioned in the themes.yml file.
      const themesString = await fs.readFile(themesFile, 'utf8');
      const themes = yaml.load(themesString, {
        filename: 'themes.yml',
        schema: yaml.FAILSAFE_SCHEMA,
      });

      if (!themes || typeof themes !== 'object') {
        throw new Error('Invalid themes.yml file');
      }

      for (const themePath of Object.values(themes)) {
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
        entrypoints[path.basename(themePath)] = path.resolve(
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
  };
}

/* This plugins handles Mastodon's theme system
 */

import fs from 'node:fs/promises';
import path from 'node:path';

import yaml from 'js-yaml';
import type { Plugin } from 'vite';

type Themes = Record<string, string>;

export function MastodonThemes(): Plugin {
  let projectRoot = '';
  let jsRoot = '';

  return {
    name: 'mastodon-themes',
    async config(userConfig) {
      if (!userConfig.root || !userConfig.envDir) {
        throw new Error('Unknown project directory');
      }
      projectRoot = userConfig.envDir;
      jsRoot = userConfig.root;

      let entrypoints: Record<string, string> = {};

      const existingInputs = userConfig.build?.rollupOptions?.input;

      if (typeof existingInputs === 'string') {
        entrypoints[path.basename(existingInputs)] = existingInputs;
      } else if (Array.isArray(existingInputs)) {
        for (const input of existingInputs) {
          if (typeof input === 'string') {
            entrypoints[path.basename(input)] = input;
          }
        }
      } else if (typeof existingInputs === 'object') {
        entrypoints = existingInputs;
      }

      // Get all files mentioned in the themes.yml file.
      const themes = await loadThemesFromConfig(projectRoot);
      for (const [themeName, themePath] of Object.entries(themes)) {
        entrypoints[`themes/${themeName}`] = path.resolve(jsRoot, themePath);
      }

      return {
        build: {
          rollupOptions: {
            input: entrypoints,
          },
        },
      };
    },
    async configureServer(server) {
      const themes = await loadThemesFromConfig(projectRoot);
      server.middlewares.use((req, res, next) => {
        if (!req.url?.startsWith('/packs-dev/themes/')) {
          next();
          return;
        }

        // Rewrite the URL to the entrypoint if it matches a theme.
        if (isThemeFile(req.url ?? '', themes)) {
          const themeName = pathToThemeName(req.url ?? '');
          req.url = `/packs-dev/${themes[themeName]}`;
        }
        next();
      });
    },
    async handleHotUpdate({ modules, server }) {
      if (modules.length === 0) {
        return;
      }
      const themes = await loadThemesFromConfig(projectRoot);
      const themePathToName = new Map(
        Object.entries(themes).map(([themeName, themePath]) => [
          path.resolve(jsRoot, themePath),
          `/themes/${themeName}`,
        ]),
      );
      const themeNames = new Set<string>();

      const addIfMatches = (file: string | null) => {
        if (!file) {
          return false;
        }
        const themeName = themePathToName.get(file);
        if (themeName) {
          themeNames.add(themeName);
          return true;
        }
        return false;
      };

      for (const module of modules) {
        if (!addIfMatches(module.file)) {
          for (const importer of module.importers) {
            addIfMatches(importer.file);
          }
        }
      }

      if (themeNames.size > 0) {
        server.ws.send({
          type: 'update',
          updates: Array.from(themeNames).map((themeName) => ({
            type: 'css-update',
            path: themeName,
            acceptedPath: themeName,
            timestamp: Date.now(),
          })),
        });
      }
    },
  };
}

async function loadThemesFromConfig(root: string) {
  const themesFile = path.resolve(root, 'config/themes.yml');
  const themes: Themes = {};

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
      console.warn(`Invalid theme path "${themePath}" in themes.yml, skipping`);
      continue;
    }
    themes[themeName] = themePath;
  }

  if (Object.keys(themes).length === 0) {
    throw new Error('No valid themes found in themes.yml');
  }

  return themes;
}

function pathToThemeName(file: string) {
  const basename = path.basename(file);
  return basename.split(/[.?]/)[0] ?? '';
}

function isThemeFile(file: string, themes: Themes) {
  if (!file.includes('/themes/')) {
    return false;
  }

  const basename = pathToThemeName(file);
  return basename in themes;
}

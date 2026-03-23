/* This plugins handles glitch-soc's specific theming system
 */

import fs from 'node:fs/promises';
import path from 'node:path';

import glob from 'fast-glob';
import yaml from 'js-yaml';
import type { Plugin } from 'vite';

interface Flavour {
  pack_directory: string;
}

export function GlitchThemes(): Plugin {
  let jsRoot = '';
  const entrypoints: Record<string, string> = {};

  return {
    name: 'glitch-themes',
    async config(userConfig) {
      const existingInputs = userConfig.build?.rolldownOptions?.input;

      if (typeof existingInputs === 'string') {
        entrypoints[path.basename(existingInputs)] = existingInputs;
      } else if (Array.isArray(existingInputs)) {
        for (const input of existingInputs) {
          if (typeof input === 'string') {
            entrypoints[path.basename(input)] = input;
          }
        }
      } else if (typeof existingInputs === 'object') {
        Object.assign(entrypoints, existingInputs);
      }

      if (!userConfig.root || !userConfig.envDir) {
        throw new Error('Unknown project directory');
      }

      jsRoot = userConfig.root;

      const glitchFlavourFiles = glob.sync(
        path.resolve(userConfig.root, 'flavours/*/theme.yml'),
      );

      for (const flavourFile of glitchFlavourFiles) {
        const flavourName = path.basename(path.dirname(flavourFile));
        const flavourString = await fs.readFile(flavourFile, 'utf8');
        const flavourDef = yaml.load(flavourString, {
          filename: 'theme.yml',
          schema: yaml.FAILSAFE_SCHEMA,
        }) as Flavour;

        const flavourEntrypoints = glob.sync(
          `${flavourDef.pack_directory}/*.{ts,tsx,js,jsx}`,
        );
        for (const entrypoint of flavourEntrypoints) {
          const name = `${flavourName}/${path.basename(entrypoint)}`;
          entrypoints[name] = path.resolve(userConfig.envDir, entrypoint);
        }

        // Skins
        const skinFiles = glob.sync(
          `app/javascript/skins/${flavourName}/*.{css,scss}`,
        );
        for (const entrypoint of skinFiles) {
          const name = `skins/${flavourName}/${path.basename(entrypoint)}`;
          entrypoints[name] = path.resolve(userConfig.envDir, entrypoint);
        }

        const alternateSkinFiles = glob.sync(
          `app/javascript/skins/${flavourName}/*/{index,common,application}.{css,scss}`,
        );
        for (const entrypoint of alternateSkinFiles) {
          const name = `skins/${flavourName}/${path.basename(path.dirname(entrypoint))}`;
          entrypoints[name] = path.resolve(userConfig.envDir, entrypoint);
        }
      }

      return {
        build: {
          rolldownOptions: {
            input: entrypoints,
          },
        },
      };
    },
    configureServer(server) {
      server.middlewares.use((req, res, next) => {
        if (!req.url?.startsWith('/packs-dev/skins/')) {
          next();
          return;
        }

        // Rewrite the URL to the entrypoint if it matches a theme.
        const filename = req.url.slice(11).split(/[.?]/)[0] ?? '';
        if (filename in entrypoints) {
          req.url = `/packs-dev/${entrypoints[filename]}`;
        }
        next();
      });
    },
    handleHotUpdate({ modules, server }) {
      if (modules.length === 0) {
        return;
      }
      // Unlike upstream, we don't need to look up, we can deduce the theme
      // solely from the path name
      const baseRoot = path.join(jsRoot, 'skins');
      const themeNames = new Set<string>();

      const addIfMatches = (file: string | null) => {
        if (!file) {
          return false;
        }
        const segments = path.relative(baseRoot, file).split(path.sep);
        if (
          segments.length >= 2 &&
          segments.length < 4 &&
          segments[0] !== '..' &&
          segments[1]
        ) {
          const themeName = `skins/${segments[0]}/${path.basename(segments[1], path.extname(segments[1]))}`;
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

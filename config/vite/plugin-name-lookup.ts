import { relative, extname } from 'node:path';

import type { Plugin } from 'vite';

export function MastodonNameLookup(): Plugin {
  const nameMap = new Map<string, string>();

  let root = '';

  return {
    name: 'mastodon-name-lookup',
    applyToEnvironment(environment) {
      return !!environment.config.build.manifest;
    },
    configResolved(userConfig) {
      root = userConfig.root;
    },
    generateBundle(options, bundle) {
      if (!root) {
        throw new Error(
          'MastodonNameLookup plugin requires the root to be set in the config.',
        );
      }

      // Iterate over all chunks in the bundle and create a lookup map
      for (const file in bundle) {
        const chunk = bundle[file];
        if (
          chunk?.type !== 'chunk' ||
          !chunk.isEntry ||
          !chunk.facadeModuleId
        ) {
          continue;
        }

        const relativePath = relative(
          root,
          sanitizeFileName(chunk.facadeModuleId),
        );
        const ext = extname(relativePath);
        const name = chunk.name.replace(ext, '');
        nameMap.set(name, relativePath);
      }

      // Build the lookup object and emit it as an asset
      const lookupObject: Record<string, string> = nameMap.entries().reduce(
        (acc, [name, fileName]) => ({
          ...acc,
          [name]: fileName,
        }),
        {},
      );
      this.emitFile({
        type: 'asset',
        fileName: '.vite/manifest-lookup.json',
        source: JSON.stringify(lookupObject, null, 2),
      });
    },
  };
}

// Taken from https://github.com/rollup/rollup/blob/4f69d33af3b2ec9320c43c9e6c65ea23a02bdde3/src/utils/sanitizeFileName.ts
// https://datatracker.ietf.org/doc/html/rfc2396
// eslint-disable-next-line no-control-regex
const INVALID_CHAR_REGEX = /[\u0000-\u001F"#$%&*+,:;<=>?[\]^`{|}\u007F]/g;

function sanitizeFileName(name: string): string {
  return name.replace(INVALID_CHAR_REGEX, '');
}

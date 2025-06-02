import { dirname, basename, extname, relative } from 'node:path';

import type { Plugin } from 'vite';

export function MastodonNameLookup(): Plugin {
  const chunkNames = new Set<string>();
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
        if (chunk?.type !== 'chunk') {
          continue;
        }
        // Virtual chunks
        let fileName = `_${chunk.fileName}`;
        if (chunk.facadeModuleId) {
          fileName = relative(root, chunk.facadeModuleId);
        }
        fileName = sanitizeFileName(fileName);
        if (!chunkNames.has(chunk.name)) {
          chunkNames.add(chunk.name);
          nameMap.set(chunk.name, fileName);
          continue;
        }

        let newName = chunk.name;
        if (chunk.fileName) {
          newName = chunk.fileName.replace(/-[a-z0-9]{8}\.js/i, '');
        } else if (chunk.facadeModuleId) {
          newName = `${dirname(chunk.facadeModuleId)}-${basename(chunk.facadeModuleId, extname(chunk.facadeModuleId))}`;
        }

        const originalNewName = newName;
        let counter = 0;
        while (chunkNames.has(newName)) {
          counter++;
          newName = `${originalNewName}-${counter}`;
        }
        chunkNames.add(newName);
        nameMap.set(newName, fileName);
        chunk.name = newName;
      }

      // Build the lookup object and emit it as an asset
      const lookupObject = nameMap.entries().reduce(
        (acc, [name, fileName]) => ({
          ...acc,
          [name]: fileName,
        }),
        {} as Record<string, string>,
      );
      this.emitFile({
        type: 'asset',
        fileName: '.vite/lookup.json',
        source: JSON.stringify(lookupObject, null, 2),
      });
    },
  };
}

// Taken from https://github.com/rollup/rollup/blob/4f69d33af3b2ec9320c43c9e6c65ea23a02bdde3/src/utils/sanitizeFileName.ts
// https://datatracker.ietf.org/doc/html/rfc2396
// eslint-disable-next-line no-control-regex
const INVALID_CHAR_REGEX = /[\u0000-\u001F"#$%&*+,:;<=>?[\]^`{|}\u007F]/g;
const DRIVE_LETTER_REGEX = /^[a-z]:/i;

function sanitizeFileName(name: string): string {
  const match = DRIVE_LETTER_REGEX.exec(name);
  const driveLetter = match ? match[0] : '';

  // A `:` is only allowed as part of a windows drive letter (ex: C:\foo)
  // Otherwise, avoid them because they can refer to NTFS alternate data streams.
  return (
    driveLetter +
    name.slice(driveLetter.length).replace(INVALID_CHAR_REGEX, '_')
  );
}

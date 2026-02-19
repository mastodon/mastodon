// Heavily inspired by https://github.com/ElMassimo/vite_ruby

import { createHash } from 'node:crypto';
import fs from 'node:fs/promises';
import path from 'node:path';

import glob from 'fast-glob';
import type { Plugin } from 'vite';

interface AssetManifestChunk {
  file: string;
  integrity: string;
}

const ALGORITHM = 'sha384';

export function MastodonAssetsManifest(): Plugin {
  let manifest: string | boolean = true;
  let jsRoot = '';

  return {
    name: 'mastodon-assets-manifest',
    applyToEnvironment(environment) {
      return !!environment.config.build.manifest;
    },
    configResolved(resolvedConfig) {
      manifest = resolvedConfig.build.manifest;
      jsRoot = resolvedConfig.root;
    },
    async generateBundle() {
      // Glob all assets and return an array of absolute paths.
      const assetPaths = await glob('{fonts,icons,images}/**/*', {
        cwd: jsRoot,
        absolute: true,
      });

      const assetManifest: Record<string, AssetManifestChunk> = {};
      const excludeExts = ['', '.md'];
      for (const file of assetPaths) {
        // Exclude files like markdown or README files with no extension.
        const ext = path.extname(file);
        if (excludeExts.includes(ext)) {
          continue;
        }

        // Read the file and emit it as an asset.
        const contents = await fs.readFile(file);
        const ref = this.emitFile({
          name: path.basename(file),
          type: 'asset',
          source: contents,
        });
        const hashedFilename = this.getFileName(ref);

        // With the emitted file information, hash the contents and store in manifest.
        const name = path.relative(jsRoot, file);
        const hash = createHash(ALGORITHM)
          .update(contents)
          .digest()
          .toString('base64');
        assetManifest[name] = {
          file: hashedFilename,
          integrity: `${ALGORITHM}-${hash}`,
        };
      }

      if (Object.keys(assetManifest).length === 0) {
        console.warn('Asset manifest is empty');
        return;
      }

      // Get manifest location and emit the manifest.
      const manifestDir =
        typeof manifest === 'string' ? path.dirname(manifest) : '.vite';
      const fileName = `${manifestDir}/manifest-assets.json`;

      this.emitFile({
        fileName,
        type: 'asset',
        source: JSON.stringify(assetManifest, null, 2),
      });
    },
  };
}

import { createHash } from 'node:crypto';
import { promises as fs } from 'node:fs';
import { resolve } from 'node:path';

import type { Plugin, Manifest } from 'vite';

export type Algorithm = 'sha256' | 'sha384' | 'sha512';

export interface Options {
  /**
   * Which hashing algorithms to use when calculate the integrity hash for each
   * asset in the manifest.
   * @default ['sha384']
   */
  algorithms?: Algorithm[];
}

declare module 'vite' {
  interface ManifestChunk {
    integrity: string;
  }
}

export function manifestSRI(options: Options = {}): Plugin {
  const { algorithms = ['sha384'] } = options;

  return {
    name: 'vite-plugin-manifest-sri',
    apply: 'build',
    enforce: 'post',
    async writeBundle({ dir }) {
      await augmentManifest('manifest.json', algorithms, dir ?? '');
    },
  };
}

async function augmentManifest(
  manifestPath: string,
  algorithms: string[],
  outDir: string,
) {
  const resolveInOutDir = (path: string) => resolve(outDir, path);
  manifestPath = resolveInOutDir(manifestPath);

  const manifest: Manifest | undefined = await fs
    .readFile(manifestPath, 'utf-8')
    .then((file) => JSON.parse(file) as Manifest);

  if (manifest) {
    await Promise.all(
      Object.values(manifest).map(async (chunk) => {
        chunk.integrity = integrityForAsset(
          await fs.readFile(resolveInOutDir(chunk.file)),
          algorithms,
        );
      }),
    );
    await fs.writeFile(manifestPath, JSON.stringify(manifest, null, 2));
  }
}

function integrityForAsset(source: Buffer, algorithms: string[]) {
  return algorithms
    .map((algorithm) => calculateIntegrityHash(source, algorithm))
    .join(' ');
}

export function calculateIntegrityHash(source: Buffer, algorithm: string) {
  const hash = createHash(algorithm).update(source).digest().toString('base64');
  return `${algorithm.toLowerCase()}-${hash}`;
}

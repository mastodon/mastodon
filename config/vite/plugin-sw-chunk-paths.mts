/* The service worker is built as a regular Vite entry point and is served from
   `/sw.js` (a symlink to `packs/sw.js`), while the chunks it depends on live in
   the build output directory (e.g. `/packs/`).

   Browsers resolve a module's static import specifiers relative to the *URL* of
   the script, not its location on disk. Because the worker is served from the
   root, relative specifiers such as `./chunk-abc123.js` resolve to
   `/chunk-abc123.js` and return a 404, which prevents the service worker from
   installing.

   This plugin rewrites those relative specifiers in the service worker output
   to absolute paths pointing at the build output directory, so they resolve
   correctly regardless of the URL the worker is served from.
*/

import type { Plugin, ResolvedConfig } from 'vite';

const SERVICE_WORKER_FILENAME = 'sw.js';

export function MastodonServiceWorkerChunkPaths(): Plugin {
  let config: ResolvedConfig;

  return {
    name: 'mastodon-sw-chunk-paths',
    configResolved(resolvedConfig) {
      config = resolvedConfig;
    },
    renderChunk(code, chunk) {
      if (chunk.fileName !== SERVICE_WORKER_FILENAME) {
        return null;
      }

      // Resolve the base from the final Vite config rather than receiving it as
      // an argument, so forks or other plugins that alter `base` are respected.
      // Vite normalises `base` to always include a trailing slash.
      const { base } = config;

      // Drive the rewrite from the chunk's actual dependency list rather than a
      // generic regex, so we only ever touch real (hashed) chunk specifiers and
      // never accidentally match similar-looking text inside string literals.
      const dependencies = [...chunk.imports, ...chunk.dynamicImports];

      let rewritten = code;
      for (const dependency of dependencies) {
        // The worker sits at the root of the output directory, so each
        // dependency is imported with a leading `./`.
        rewritten = rewritten
          .replaceAll(`"./${dependency}"`, `"${base}${dependency}"`)
          .replaceAll(`'./${dependency}'`, `'${base}${dependency}'`);
      }

      if (rewritten === code) {
        return null;
      }

      // Only import specifiers are changed, so the existing source map stays
      // accurate enough; returning `null` avoids a spurious sourcemap warning.
      return { code: rewritten, map: null };
    },
  };
}

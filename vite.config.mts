import { readdir } from 'node:fs/promises';
import path from 'node:path';

import { optimizeLodashImports } from '@optimize-lodash/rollup-plugin';
import legacy from '@vitejs/plugin-legacy';
import react from '@vitejs/plugin-react';
import postcssPresetEnv from 'postcss-preset-env';
import Compress from 'rollup-plugin-gzip';
import { visualizer } from 'rollup-plugin-visualizer';
import {
  PluginOption,
  defineConfig,
  UserConfigFnPromise,
  UserConfig,
} from 'vite';
import manifestSRI from 'vite-plugin-manifest-sri';
import { VitePWA } from 'vite-plugin-pwa';
import svgr from 'vite-plugin-svgr';
import tsconfigPaths from 'vite-tsconfig-paths';

import { MastodonAssetsManifest } from './config/vite/plugin-assets-manifest';
import { MastodonEmojiCompressed } from './config/vite/plugin-emoji-compressed';
import { MastodonThemes } from './config/vite/plugin-mastodon-themes';
import { MastodonNameLookup } from './config/vite/plugin-name-lookup';
import { MastodonServiceWorkerLocales } from './config/vite/plugin-sw-locales';

const jsRoot = path.resolve(__dirname, 'app/javascript');

const cssAliasClasses: ReadonlyArray<string> = ['components', 'features'];

export const config: UserConfigFnPromise = async ({ mode, command }) => {
  const isProdBuild = mode === 'production' && command === 'build';

  let outDirName = 'packs-dev';
  if (mode === 'test') {
    outDirName = 'packs-test';
  } else if (mode === 'production') {
    outDirName = 'packs';
  }
  const outDir = path.resolve('public', outDirName);

  return {
    root: jsRoot,
    base: `/${outDirName}/`,
    envDir: __dirname,
    resolve: {
      alias: {
        '~/': `${jsRoot}/`,
        '@/': `${jsRoot}/`,
      },
    },
    css: {
      modules: {
        generateScopedName(name, filename) {
          let prefix = '';

          // Use the top two segments of the path as the prefix.
          const [parentDirName, dirName] = path
            .dirname(filename)
            .split(path.sep)
            .slice(-2)
            .map((dir) => dir.toLowerCase());

          // If the parent directory is in the cssAliasClasses list, use
          // the first four letters of it as the prefix, otherwise use the full name.
          if (parentDirName) {
            if (cssAliasClasses.includes(parentDirName)) {
              prefix = parentDirName.slice(0, 4);
            } else {
              prefix = parentDirName;
            }
          }

          // If we have a directory name, append it to the prefix.
          if (dirName) {
            prefix = `${prefix}_${dirName}`;
          }

          // If the file is not styles.module.scss or style.module.scss,
          // append the file base name to the prefix.
          const baseName = path.basename(
            filename,
            `.module${path.extname(filename)}`,
          );
          if (baseName !== 'styles' && baseName !== 'style') {
            prefix = `${prefix}_${baseName}`;
          }

          return `_${prefix}__${name}`;
        },
      },
      postcss: {
        plugins: [
          postcssPresetEnv({
            features: {
              'logical-properties-and-values': false,
            },
          }),
        ],
      },
    },
    server: {
      headers: {
        // This is needed in dev environment because we load the worker from `/dev-sw/dev-sw.js`,
        // but it needs to be scoped to the whole domain
        'Service-Worker-Allowed': '/',
      },
      hmr: {
        // Forcing the protocol to be insecure helps if you are proxying your dev server with SSL,
        // because Vite still tries to connect to localhost.
        protocol: 'ws',
      },
      port: 3036,
    },
    build: {
      commonjsOptions: { transformMixedEsModules: true },
      chunkSizeWarningLimit: 1 * 1024 * 1024, // 1MB
      sourcemap: true,
      emptyOutDir: mode !== 'production',
      manifest: true,
      outDir,
      assetsDir: 'assets',
      assetsInlineLimit: (filePath, _) =>
        /\.woff2?$/.exec(filePath) ? false : undefined,
      rollupOptions: {
        input: await findEntrypoints(),
        output: {
          chunkFileNames({ facadeModuleId, name }) {
            if (!facadeModuleId) {
              return '[name]-[hash].js';
            }
            if (/mastodon\/locales\/[a-zA-Z\-]+\.json/.exec(facadeModuleId)) {
              // put all locale files in `intl/`
              return 'intl/[name]-[hash].js';
            } else if (/node_modules\/@formatjs\//.exec(facadeModuleId)) {
              // use a custom name for formatjs polyfill files
              const newName = /node_modules\/@formatjs\/([^/]+)\//.exec(
                facadeModuleId,
              );

              if (newName?.[1]) {
                return `intl/[name]-${newName[1]}-[hash].js`;
              }
            } else if (name === 'index') {
              // Use a custom name for chunks, to avoid having too many of them called "index"
              const parts = facadeModuleId.split('/');

              const parent = parts.at(-2);

              if (parent) {
                return `${parent}-[name]-[hash].js`;
              }
            }
            return '[name]-[hash].js';
          },
        },
      },
    },
    experimental: {
      /**
       * Setting this causes Vite to not rely on the base config for import URLs,
       * and instead uses import.meta.url, which is what we want for proper CDN support.
       * @see https://github.com/mastodon/mastodon/pull/37310
       */
      renderBuiltUrl: () => undefined,
    },
    worker: {
      format: 'es',
    },
    plugins: [
      tsconfigPaths({ projects: [path.resolve(__dirname, 'tsconfig.json')] }),
      react({
        babel: {
          plugins: ['formatjs', 'transform-react-remove-prop-types'],
        },
      }),
      MastodonThemes(),
      MastodonAssetsManifest(),
      MastodonServiceWorkerLocales(),
      MastodonEmojiCompressed(),
      legacy({
        renderLegacyChunks: false,
        modernPolyfills: true,
      }),
      isProdBuild && (Compress() as PluginOption),
      command === 'build' &&
        manifestSRI({
          manifestPaths: ['.vite/manifest.json'],
        }),
      VitePWA({
        srcDir: path.resolve(jsRoot, 'mastodon/service_worker'),
        // We need to use injectManifest because we use our own service worker
        strategies: 'injectManifest',
        manifest: false,
        injectRegister: false,
        injectManifest: {
          // Do not inject a manifest, we don't use precache
          injectionPoint: undefined,
          buildPlugins: {
            vite: [
              // Provide a virtual import with only the locales used in the ServiceWorker
              MastodonServiceWorkerLocales(),
              MastodonEmojiCompressed(),
            ],
          },
        },
        // Force the output location, because we have a symlink in `public/sw.js`
        outDir: path.resolve(__dirname, 'public/packs'),
        devOptions: {
          enabled: true,
          type: 'module',
        },
      }),
      svgr(),
      // Old library types need to be converted
      optimizeLodashImports() as PluginOption,
      !!process.env.ANALYZE_BUNDLE_SIZE &&
        (visualizer({
          template: process.env.CI ? 'raw-data' : 'treemap',
        }) as PluginOption),
      MastodonNameLookup(),
    ],
  } satisfies UserConfig;
};

async function findEntrypoints() {
  const entrypoints: Record<string, string> = {};

  // First, JS entrypoints
  const jsEntrypointsDir = path.resolve(jsRoot, 'entrypoints');
  const jsEntrypoints = await readdir(jsEntrypointsDir, {
    withFileTypes: true,
  });
  const jsExtTest = /\.[jt]sx?$/;
  for (const file of jsEntrypoints) {
    if (file.isFile() && jsExtTest.test(file.name)) {
      entrypoints[file.name.replace(jsExtTest, '')] = path.resolve(
        jsEntrypointsDir,
        file.name,
      );
    }
  }

  // Next, SCSS entrypoints
  const scssEntrypointsDir = path.resolve(jsRoot, 'styles/entrypoints');
  const scssEntrypoints = await readdir(scssEntrypointsDir, {
    withFileTypes: true,
  });
  const scssExtTest = /\.s?css$/;
  for (const file of scssEntrypoints) {
    if (file.isFile() && scssExtTest.test(file.name)) {
      entrypoints[file.name.replace(scssExtTest, '')] = path.resolve(
        scssEntrypointsDir,
        file.name,
      );
    }
  }

  return entrypoints;
}

export default defineConfig(config);

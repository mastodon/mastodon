import path from 'node:path';
import { readdir } from 'node:fs/promises';

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
import { viteStaticCopy } from 'vite-plugin-static-copy';
import svgr from 'vite-plugin-svgr';
import tsconfigPaths from 'vite-tsconfig-paths';

import { MastodonServiceWorkerLocales } from './config/vite/plugin-sw-locales';
import { MastodonEmojiCompressed } from './config/vite/plugin-emoji-compressed';
import { MastodonThemes } from './config/vite/plugin-mastodon-themes';
import { MastodonNameLookup } from './config/vite/plugin-name-lookup';
import { MastodonAssetsManifest } from './config/vite/plugin-assets-manifest';

const jsRoot = path.resolve(__dirname, 'app/javascript');

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
      viteStaticCopy({
        targets: [
          {
            src: path.resolve(
              __dirname,
              'node_modules/emojibase-data/**/compact.json',
            ),
            dest: 'emoji',
            rename(_name, ext, dir) {
              const locale = path.basename(path.dirname(dir));
              return `${locale}.${ext}`;
            },
          },
        ],
      }),
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
      !!process.env.ANALYZE_BUNDLE_SIZE && (visualizer() as PluginOption),
      MastodonNameLookup(),
    ],
  } satisfies UserConfig;
};

async function findEntrypoints() {
  const entrypoints: Record<string, string> = {};

  // First, JS entrypoints
  const jsEntrypoints = await readdir(path.resolve(jsRoot, 'entrypoints'), {
    withFileTypes: true,
  });
  const jsExtTest = /\.[jt]sx?$/;
  for (const file of jsEntrypoints) {
    if (file.isFile() && jsExtTest.test(file.name)) {
      entrypoints[file.name.replace(jsExtTest, '')] = path.resolve(
        file.parentPath,
        file.name,
      );
    }
  }

  // Next, SCSS entrypoints
  const scssEntrypoints = await readdir(
    path.resolve(jsRoot, 'styles/entrypoints'),
    { withFileTypes: true },
  );
  const scssExtTest = /\.s?css$/;
  for (const file of scssEntrypoints) {
    if (file.isFile() && scssExtTest.test(file.name)) {
      entrypoints[file.name.replace(scssExtTest, '')] = path.resolve(
        file.parentPath,
        file.name,
      );
    }
  }

  return entrypoints;
}

export default defineConfig(config);

import fs from 'node:fs/promises';
import path from 'node:path';

import { optimizeLodashImports } from '@optimize-lodash/rollup-plugin';
import react from '@vitejs/plugin-react';
import { PluginOption } from 'vite';
import svgr from 'vite-plugin-svgr';
import { visualizer } from 'rollup-plugin-visualizer';
import RailsPlugin from 'vite-plugin-rails';
import { VitePWA } from 'vite-plugin-pwa';

import { defineConfig, UserConfigFnPromise, UserConfig } from 'vite';
import postcssPresetEnv from 'postcss-preset-env';

import { MastodonServiceWorkerLocales } from './config/vite/plugin-sw-locales';
import { MastodonEmojiCompressed } from './config/vite/plugin-emoji-compressed';

const jsRoot = path.resolve(__dirname, 'app/javascript');
const entrypointRoot = path.resolve(jsRoot, 'entrypoints');

export const config: UserConfigFnPromise = async ({ mode, command }) => {
  const entrypointFiles = await fs.readdir(entrypointRoot);
  const entrypoints: Record<string, string> = entrypointFiles.reduce(
    (acc, file) => {
      const name = path.basename(file).replace(/\.tsx?$/, '');
      acc[name] = path.resolve(entrypointRoot, file);
      return acc;
    },
    {} as Record<string, string>,
  );
  return {
    root: jsRoot,
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
    resolve: {
      alias: {
        mastodon: path.resolve(jsRoot, 'mastodon'),
        '@': jsRoot,
      },
    },
    server: {
      headers: {
        // This is needed in dev environment because we load the worker from `/dev-sw/dev-sw.js`,
        // but it needs to be scoped to the whole domain
        'Service-Worker-Allowed': '/',
      },
    },
    build: {
      commonjsOptions: { transformMixedEsModules: true },
      chunkSizeWarningLimit: 1 * 1024 * 1024, // 1MB
      manifest: 'manifest.json',
      sourcemap: true,
      rollupOptions: {
        input: entrypoints,
        output: {
          chunkFileNames(chunkInfo) {
            if (!chunkInfo.facadeModuleId) {
              return '[name]-[hash].js';
            }
            if (
              /mastodon\/locales\/[a-zA-Z-]+\.json/.exec(
                chunkInfo.facadeModuleId,
              )
            ) {
              // put all locale files in `intl/`
              return `intl/[name]-[hash].js`;
            } else if (
              /node_modules\/@formatjs\//.exec(chunkInfo.facadeModuleId)
            ) {
              // use a custom name for formatjs polyfill files
              const name = /node_modules\/@formatjs\/([^/]+)\//.exec(
                chunkInfo.facadeModuleId,
              );

              if (name?.[1]) {
                return `intl/[name]-${name[1]}-[hash].js`;
              }
            } else if (chunkInfo.name === 'index' && chunkInfo.facadeModuleId) {
              // Use a custom name for chunks, to avoid having too many of them called "index"
              const parts = chunkInfo.facadeModuleId.split('/');

              const parent = parts.at(-2);

              if (parent) {
                return `${parent}-[name]-[hash].js`;
              }
            }
            return `[name]-[hash].js`;
          },
        },
      },
    },
    plugins: [
      RailsPlugin({
        compress: mode !== 'production' && command === 'build',
      }),
      react({
        babel: {
          plugins: ['formatjs', 'transform-react-remove-prop-types'],
        },
      }),
      MastodonServiceWorkerLocales(),
      MastodonEmojiCompressed(),
      VitePWA({
        srcDir: 'mastodon/service_worker',
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
    ],
  } satisfies UserConfig;
};

export default defineConfig(config);

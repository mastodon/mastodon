import path from 'node:path';

import { optimizeLodashImports } from '@optimize-lodash/rollup-plugin';
import legacy from '@vitejs/plugin-legacy';
import react from '@vitejs/plugin-react';
import { PluginOption } from 'vite';
import { visualizer } from 'rollup-plugin-visualizer';
import { VitePWA } from 'vite-plugin-pwa';
import RailsPlugin from 'vite-plugin-rails';
import { viteStaticCopy } from 'vite-plugin-static-copy';
import svgr from 'vite-plugin-svgr';
import tsconfigPaths from 'vite-tsconfig-paths';

import { defineConfig, UserConfigFnPromise, UserConfig } from 'vite';
import postcssPresetEnv from 'postcss-preset-env';

import { MastodonServiceWorkerLocales } from './config/vite/plugin-sw-locales';
import { MastodonEmojiCompressed } from './config/vite/plugin-emoji-compressed';
import { MastodonThemes } from './config/vite/plugin-mastodon-themes';
import { MastodonNameLookup } from './config/vite/plugin-name-lookup';

const jsRoot = path.resolve(__dirname, 'app/javascript');

export const config: UserConfigFnPromise = async ({ mode, command }) => {
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
      sourcemap: true,
      rollupOptions: {
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
      RailsPlugin({
        compress: mode === 'production' && command === 'build',
        sri: {
          manifestPaths: ['.vite/manifest.json', '.vite/manifest-assets.json'],
        },
      }),
      MastodonThemes(),
      react({
        babel: {
          plugins: ['formatjs', 'transform-react-remove-prop-types'],
        },
      }),
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
      MastodonNameLookup(),
    ],
  } satisfies UserConfig;
};

export default defineConfig(config);

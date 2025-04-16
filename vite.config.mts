/// <reference types="vitest/config" />

import fs from 'node:fs/promises';
import path from 'node:path';

import { optimizeLodashImports } from '@optimize-lodash/rollup-plugin';
import react from '@vitejs/plugin-react';
import { loadEnv, PluginOption } from 'vite';
import svgr from 'vite-plugin-svgr';
import { analyzer } from 'vite-bundle-analyzer';
import RailsPlugin from 'vite-plugin-rails';
import { VitePWA } from 'vite-plugin-pwa';

import {
  configDefaults,
  defineConfig,
  ViteUserConfig,
  UserConfigFnPromise,
} from 'vitest/config';
import postcssPresetEnv from 'postcss-preset-env';

import { MastodonServiceWorkerLocales } from './config/vite/plugin-sw-locales';

const jsRoot = path.resolve(__dirname, 'app/javascript');
const entrypointRoot = path.resolve(jsRoot, 'entrypoints');

const config: UserConfigFnPromise = async ({ mode }) => {
  const entrypointFiles = await fs.readdir(entrypointRoot);
  const entrypoints: Record<string, string> = entrypointFiles.reduce(
    (acc, file) => {
      const name = path.basename(file).replace(/\.tsx?$/, '');
      acc[name] = path.resolve(entrypointRoot, file);
      return acc;
    },
    {} as Record<string, string>,
  );
  const env = loadEnv(mode, process.cwd());
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
      hmr: {
        clientPort: parseInt(env.VITE_HMR_PORT ?? '3000'),
      },
    },
    build: {
      commonjsOptions: { transformMixedEsModules: true },
      outDir: path.resolve(__dirname, '.dist'),
      emptyOutDir: true,
      manifest: 'manifest.json',
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
      RailsPlugin(),
      react(),
      MastodonServiceWorkerLocales(),
      VitePWA({
        srcDir: 'mastodon/service_worker',
        filename: 'sw.js',
        manifest: false,
        injectRegister: null,
        injectManifest: {
          buildPlugins: {
            vite: [
              // Provide a virtual import with only the locales used in the ServiceWorker
              MastodonServiceWorkerLocales(),
            ],
          },
          globIgnores: [
            // Do not preload those files
            'intl/*.js',
            'extra_polyfills-*.js',
            'polyfill-force-*.js',
            'assets/mailer-*.{js,css}',
          ],
          maximumFileSizeToCacheInBytes: 2 * 1_024 * 1_024, // 2 MiB
        },
        devOptions: {
          enabled: true,
          type: 'module',
        },
      }),
      svgr(),
      // manifestSRI(),
      // Old library types need to be converted
      optimizeLodashImports() as PluginOption,
      !!process.env.ANALYZE_BUNDLE_SIZE && analyzer({ analyzerMode: 'static' }),
    ],
    test: {
      environment: 'jsdom',
      include: [
        ...configDefaults.include,
        '**/__tests__/**/*.{js,mjs,cjs,ts,mts,cts,jsx,tsx}',
      ],
      exclude: [
        ...configDefaults.exclude,
        '**/node_modules/**',
        'vendor/**',
        'config/**',
        'log/**',
        'public/**',
        'tmp/**',
      ],
      globals: true,
    },
  } satisfies ViteUserConfig;
};

export default defineConfig(config);

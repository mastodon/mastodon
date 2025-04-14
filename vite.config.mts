/// <reference types="vitest" />

import path from 'path';

import react from '@vitejs/plugin-react';
import svgr from 'vite-plugin-svgr';
import { defineConfig, configDefaults } from 'vitest/config';
import postcssPresetEnv from 'postcss-preset-env';

import { manifestSRI } from './config/vite/plugin-manifest-sri';

export default defineConfig({
  root: './app/javascript/entrypoints',
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
      mastodon: path.resolve(__dirname, 'app/javascript/mastodon'),
      '@': path.resolve(__dirname, 'app/javascript'),
    },
  },
  build: {
    commonjsOptions: { transformMixedEsModules: true },
    outDir: path.resolve(__dirname, '.dist'),
    emptyOutDir: true,
    manifest: 'manifest.json',
    rollupOptions: {
      input: {
        admin: path.resolve(__dirname, 'app/javascript/entrypoints/admin.tsx'),
        application: path.resolve(
          __dirname,
          'app/javascript/entrypoints/application.ts',
        ),
        twoFactor: path.resolve(
          __dirname,
          'app/javascript/entrypoints/two_factor_authentication.ts',
        ),
      },
      output: {
        chunkFileNames(chunkInfo) {
          if (
            /mastodon\/locales\/[a-zA-Z-]+\.json/.exec(chunkInfo.facadeModuleId)
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
  plugins: [react(), svgr(), manifestSRI()],
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
});

import path from 'node:path';

import { defineConfig } from 'vite';

import { manifestSRI } from './config/vite/plugin-manifest-sri';

// eslint-disable-next-line import/no-default-export
export default defineConfig({
  root: './app/javascript/entrypoints',
  build: {
    commonjsOptions: { transformMixedEsModules: true },
    outDir: path.resolve(__dirname, '.dist'),
    emptyOutDir: true,
    manifest: 'manifest.json',
    rollupOptions: {
      output: {
        chunkFileNames: (chunkInfo) => {
          if (
            chunkInfo.facadeModuleId?.match(
              /mastodon\/locales\/[a-zA-Z-]+\.json/,
            )
          ) {
            // put all locale files in `intl/`
            return `intl/[name]-[hash].js`;
          } else if (
            chunkInfo.facadeModuleId?.match(/node_modules\/@formatjs\//)
          ) {
            // use a custom name for formatjs polyfill files
            const name = /node_modules\/@formatjs\/([^/]+)\//.exec(
              chunkInfo.facadeModuleId,
            );

            if (name?.[1]) return `intl/[name]-${name[1]}-[hash].js`;
          } else if (chunkInfo.name === 'index' && chunkInfo.facadeModuleId) {
            // Use a custom name for chunks, to avoid having too many of them called "index"
            const parts = chunkInfo.facadeModuleId.split('/');

            const parent = parts.at(-2);

            if (parent) return `${parent}-[name]-[hash].js`;
          }
          return `[name]-[hash].js`;
        },
      },
    },
  },
  plugins: [manifestSRI()],
  resolve: {
    alias: {
      mastodon: path.resolve(__dirname, 'app/javascript/mastodon'),
      '@': path.resolve(__dirname, 'app/javascript'),
    },
  },
});

/// <reference types="vitest" />

import fs from 'fs';
import path from 'path';

import { optimizeLodashImports } from '@optimize-lodash/rollup-plugin';
import react from '@vitejs/plugin-react';
import { visualizer } from 'rollup-plugin-visualizer';
import { defineConfig } from 'vite';
import CompressionPlugin from 'vite-plugin-compression';
import RubyPlugin from 'vite-plugin-ruby';
import svgr from 'vite-plugin-svgr';
import { configDefaults } from 'vitest/config';

const sourceCodeDir = 'app/javascript';
const items = fs.readdirSync(sourceCodeDir);
const directories = items.filter((item) =>
  fs.lstatSync(path.join(sourceCodeDir, item)).isDirectory(),
);
const aliasesFromJavascriptRoot: Record<string, string> = {};
directories.forEach((directory) => {
  aliasesFromJavascriptRoot[directory] = path.resolve(
    __dirname,
    sourceCodeDir,
    directory,
  );
});

// eslint-disable-next-line import/no-default-export
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        // Use a custom name for chunks, to avoid having too many of them called "index"
        chunkFileNames: (chunkInfo) => {
          if (chunkInfo.name === 'index' && chunkInfo.facadeModuleId) {
            const parts = chunkInfo.facadeModuleId.split('/');

            const parent = parts.at(-2);

            if (parent) return `${parent}-[name]-[hash].js`;
          }
          return `[name]-[hash].js`;
        },
      },
    },
  },
  resolve: {
    alias: {
      ...aliasesFromJavascriptRoot,
      // images: path.resolve(__dirname, './app/javascript/images'),
    },
  },
  plugins: [
    RubyPlugin(),
    react({
      include: ['**/*.jsx', '**/*.tsx'],
      babel: {
        plugins: [
          //  ['@babel/proposal-decorators', { legacy: true }],
          'formatjs',
          'preval',
          'transform-react-remove-prop-types',
        ],
      },
    }),
    svgr(),
    optimizeLodashImports(),
    CompressionPlugin({ verbose: false }),
    CompressionPlugin({ verbose: false, algorithm: 'brotliCompress' }),
    !!process.env.ANALYZE_BUNDLE_SIZE &&
      visualizer({ open: true, gzipSize: true, brotliSize: true }),
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
});

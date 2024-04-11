/// <reference types="vitest" />

import fs from 'fs';
import path from 'path';

// import { optimizeLodashImports } from '@optimize-lodash/rollup-plugin';
import react from '@vitejs/plugin-react';
import RailsPlugin from 'vite-plugin-rails';
import svgr from 'vite-plugin-svgr';
import { defineConfig, configDefaults } from 'vitest/config';
import GithubActionsReporter from 'vitest-github-actions-reporter';

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

export default defineConfig({
  resolve: {
    alias: {
      ...aliasesFromJavascriptRoot,
      // images: path.resolve(__dirname, './app/javascript/images'),
    },
  },
  plugins: [
    RailsPlugin(),
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
    // optimizeLodashImports(),
    // !!process.env.ANALYZE_BUNDLE_SIZE &&
    //   visualizer({ open: true, gzipSize: true, brotliSize: true }),
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
    reporters: process.env.GITHUB_ACTIONS
      ? ['default', new GithubActionsReporter()]
      : 'default',
    globals: true,
  },
});

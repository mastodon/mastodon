/// <reference types="vitest" />

import fs from 'fs';
import path from 'path';

import react from '@vitejs/plugin-react';
import RailsPlugin from 'vite-plugin-rails';
import svgr from 'vite-plugin-svgr';
import { defineConfig, configDefaults } from 'vitest/config';

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
    },
  },
  plugins: [
    RailsPlugin(),
    react({
      include: ['**/*.jsx', '**/*.tsx'],
      babel: {
        plugins: ['formatjs', 'preval', 'transform-react-remove-prop-types'],
      },
    }),
    svgr(),
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

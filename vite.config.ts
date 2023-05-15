/// <reference types="vitest" />

import fs from 'fs';
import path from 'path';

import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import { configDefaults } from 'vitest/config';

const sourceCodeDir = 'app/javascript';
const items = fs.readdirSync(sourceCodeDir);
const directories = items.filter((item) =>
  fs.lstatSync(path.join(sourceCodeDir, item)).isDirectory()
);
const aliasesFromJavascriptRoot: Record<string, string> = {};
directories.forEach((directory) => {
  aliasesFromJavascriptRoot[directory] = path.resolve(
    __dirname,
    sourceCodeDir,
    directory
  );
});

// eslint-disable-next-line import/no-default-export
export default defineConfig({
  resolve: {
    alias: {
      ...aliasesFromJavascriptRoot,
      // can add more aliases, as "old" images or "@assets", see below
      images: path.resolve(__dirname, './app/assets/images'),
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
          'lodash',
          'preval',
          'transform-react-remove-prop-types',
        ],
      },
    }),
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

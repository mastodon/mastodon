import { resolve } from 'node:path';

import {
  configDefaults,
  defineConfig,
  TestProjectInlineConfiguration,
} from 'vitest/config';
import tsconfigPaths from 'vite-tsconfig-paths';
import react from '@vitejs/plugin-react';

import { config as viteConfig } from './vite.config.mjs';

import { storybookTest } from '@storybook/addon-vitest/vitest-plugin';

const storybookTests: TestProjectInlineConfiguration = {
  extends: true,
  plugins: [
    // See options at: https://storybook.js.org/docs/next/writing-tests/integrations/vitest-addon#storybooktest
    storybookTest({
      configDir: '.storybook',
      storybookScript: 'yarn run storybook',
    }),
  ],
  test: {
    name: 'storybook',
    browser: {
      enabled: true,
      headless: true,
      provider: 'playwright',
      instances: [{ browser: 'chromium' }],
    },
    setupFiles: [resolve(__dirname, '.storybook/vitest.setup.ts')],
  },
};

const legacyTests: TestProjectInlineConfiguration = {
  extends: true,
  test: {
    name: 'legacy-tests',
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
};

export default defineConfig(async (context) => {
  const baseConfig = await viteConfig(context);

  return {
    ...baseConfig,
    // Redeclare plugins as we don't need them all, and Ruby Vite is breaking the Vitest runner.
    plugins: [
      tsconfigPaths(),
      react({
        babel: {
          plugins: ['formatjs', 'transform-react-remove-prop-types'],
        },
      }),
    ],
    test: {
      projects: [legacyTests, storybookTests],
    },
  };
});

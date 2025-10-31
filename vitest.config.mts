import { resolve } from 'node:path';

import { storybookTest } from '@storybook/addon-vitest/vitest-plugin';
import { playwright } from '@vitest/browser-playwright';
import {
  configDefaults,
  defineConfig,
  TestProjectInlineConfiguration,
} from 'vitest/config';

import { config as viteConfig } from './vite.config.mjs';

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
      provider: playwright(),
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
    setupFiles: ['fake-indexeddb/auto'],
  },
};

export default defineConfig(async (context) => {
  const baseConfig = await viteConfig(context);

  return {
    ...baseConfig,
    test: {
      projects: [legacyTests, storybookTests],
    },
  };
});

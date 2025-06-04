import {
  configDefaults,
  defineConfig,
  TestProjectInlineConfiguration,
} from 'vitest/config';

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
    setupFiles: ['./.storybook/vitest.setup.ts'],
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
  return {
    ...(await viteConfig(context)),
    test: {
      projects: [legacyTests, storybookTests],
    },
  };
});

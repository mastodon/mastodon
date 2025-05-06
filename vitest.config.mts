import { configDefaults, defineConfig } from 'vitest/config';

import { config as viteConfig } from './vite.config.mjs';

export default defineConfig(async (context) => {
  return {
    ...(await viteConfig(context)),
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
  };
});

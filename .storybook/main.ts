import { resolve } from 'node:path';

import type { StorybookConfig } from '@storybook/react-vite';

const config: StorybookConfig = {
  stories: ['../app/javascript/**/*.stories.@(js|jsx|mjs|ts|tsx)'],
  addons: [
    '@storybook/addon-docs',
    '@storybook/addon-a11y',
    '@storybook/addon-vitest',
  ],
  framework: {
    name: '@storybook/react-vite',
    options: {},
  },
  staticDirs: [
    './static',
    // We need to manually specify the assets because of the symlink in public/sw.js
    ...[
      'avatars',
      'emoji',
      'headers',
      'sounds',
      'badge.png',
      'loading.gif',
      'loading.png',
      'oops.gif',
      'oops.png',
    ].map((path) => ({ from: `../public/${path}`, to: `/${path}` })),
    { from: '../app/javascript/images/logo.svg', to: '/custom-emoji/logo.svg' },
  ],
  viteFinal(config) {
    // For an unknown reason, Storybook does not use the root
    // from the Vite config so we need to set it manually.
    config.root = resolve(import.meta.dirname, '../app/javascript');
    return config;
  },
};

export default config;

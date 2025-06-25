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
  ],
};

export default config;

// The addon package.json incorrectly exports types, so we need to override them here.

import type { RootState } from '@/mastodon/store';

// See: https://github.com/storybookjs/storybook/blob/v9.0.4/code/addons/vitest/package.json#L70-L76
declare module '@storybook/addon-vitest/vitest-plugin' {
  export * from '@storybook/addon-vitest/dist/vitest-plugin/index';
}

type RootPathKeys = keyof RootState;

declare module 'storybook/internal/csf' {
  export interface InputType {
    reduxPath?:
      | `${RootPathKeys}.${string}`
      | [RootPathKeys, ...(string | number)[]];
  }
}

export {};

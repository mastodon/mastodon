// The addon package.json incorrectly exports types, so we need to override them here.
// See: https://github.com/storybookjs/storybook/blob/v9.0.4/code/addons/vitest/package.json#L70-L76
declare module '@storybook/addon-vitest/vitest-plugin' {
  export * from '@storybook/addon-vitest/dist/vitest-plugin/index';
}

export {};

/* eslint-disable @typescript-eslint/no-explicit-any */
// The addon package.json incorrectly exports types, so we need to override them here.

import type { PartialDeep } from 'type-fest';

import type { RootState } from '@/mastodon/store';

// See: https://github.com/storybookjs/storybook/blob/v9.0.4/code/addons/vitest/package.json#L70-L76
declare module '@storybook/addon-vitest/vitest-plugin' {
  export * from '@storybook/addon-vitest/dist/vitest-plugin/index';
}

type TypedRootState = {
  [Key in keyof RootState]?: RootState[Key] extends Immutable.OrderedCollection<any>
    ? unknown
    : PartialDeep<RootState[Key]>;
};

declare module 'storybook/internal/csf' {
  export interface InputType {
    /**
     * Connects an argument value deeply in the Redux state.
     *
     * Can either be a period separated string or an array.
     */
    reduxPath?: `${keyof TypedRootState}.${string}`;
  }

  export interface Globals {
    locale: string;
    theme: 'light' | 'dark';
    loggedIn: 'true' | 'false';
  }

  export interface Parameters {
    /** Provides the Redux state as a JS object for the component. */
    state?: TypedRootState;
    /** Callback that is run with the story arguments to generate Redux state for the component. */
    stateFn?: (args: any) => TypedRootState;
  }
}

export {};

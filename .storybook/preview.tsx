import { configureStore } from '@reduxjs/toolkit';
import { Provider } from 'react-redux';

import type { Preview } from '@storybook/react-vite';

// If you want to run the dark theme during development,
// you can change the below to `/application.scss`
import '../app/javascript/styles/mastodon-light.scss';

import { reducerWithInitialState, rootReducer } from '@/mastodon/reducers';
import { defaultMiddleware } from '@/mastodon/store/store';

const preview: Preview = {
  // Auto-generate docs: https://storybook.js.org/docs/writing-docs/autodocs
  tags: ['autodocs'],
  decorators: [
    (Story, { parameters }) => {
      const { state = {} } = parameters;
      let reducer = rootReducer;
      if (typeof state === 'object' && state) {
        reducer = reducerWithInitialState(state as Record<string, unknown>);
      }
      const store = configureStore({
        reducer,
        middleware(getDefaultMiddleware) {
          return getDefaultMiddleware(defaultMiddleware);
        },
      });
      return (
        <Provider store={store}>
          <Story />
        </Provider>
      );
    },
  ],
  parameters: {
    layout: 'centered',

    controls: {
      matchers: {
        color: /(background|color)$/i,
        date: /Date$/i,
      },
    },

    a11y: {
      // 'todo' - show a11y violations in the test UI only
      // 'error' - fail CI on a11y violations
      // 'off' - skip a11y checks entirely
      test: 'todo',
    },

    state: {},
  },
};

export default preview;

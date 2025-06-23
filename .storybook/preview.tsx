import { configureStore } from '@reduxjs/toolkit';
import { Provider } from 'react-redux';

import type { Preview } from '@storybook/react-vite';
import { http, passthrough } from 'msw';
import { initialize, mswLoader } from 'msw-storybook-addon';

// If you want to run the dark theme during development,
// you can change the below to `/application.scss`
import '../app/javascript/styles/mastodon-light.scss';

import { IntlProvider } from '@/mastodon/locales';
import { reducerWithInitialState, rootReducer } from '@/mastodon/reducers';
import { defaultMiddleware } from '@/mastodon/store/store';

// Initialize MSW
initialize();

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
    (Story) => (
      <IntlProvider>
        <Story />
      </IntlProvider>
    ),
  ],
  loaders: [mswLoader],
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

    // Force docs to use an iframe as it breaks MSW handlers.
    // See: https://github.com/mswjs/msw-storybook-addon/issues/83
    docs: {
      story: {
        inline: false,
      },
    },

    msw: {
      handlers: [
        http.get('/index.json', passthrough),
        http.get('/packs-dev/*', passthrough),
        http.get('/sounds/*', passthrough),
      ],
    },
  },
};

export default preview;

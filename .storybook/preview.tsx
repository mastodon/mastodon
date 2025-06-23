import { useEffect, useState } from 'react';

import { IntlProvider } from 'react-intl';

import { configureStore } from '@reduxjs/toolkit';
import { Provider } from 'react-redux';

import type { Preview } from '@storybook/react-vite';
import { http, passthrough } from 'msw';
import { initialize, mswLoader } from 'msw-storybook-addon';

import type { LocaleData } from '@/mastodon/locales';
import { reducerWithInitialState, rootReducer } from '@/mastodon/reducers';
import { defaultMiddleware } from '@/mastodon/store/store';

// If you want to run the dark theme during development,
// you can change the below to `/application.scss`
import '../app/javascript/styles/mastodon-light.scss';

const localeFiles = import.meta.glob('@/mastodon/locales/*.json', {
  query: { as: 'json' },
});

// Initialize MSW
initialize();

const preview: Preview = {
  // Auto-generate docs: https://storybook.js.org/docs/writing-docs/autodocs
  tags: ['autodocs'],
  globalTypes: {
    locale: {
      description: 'Locale for the story',
      toolbar: {
        title: 'Locale',
        icon: 'globe',
        items: Object.keys(localeFiles).map((path) =>
          path.replace('/mastodon/locales/', '').replace('.json', ''),
        ),
        dynamicTitle: true,
      },
    },
  },
  initialGlobals: {
    locale: 'en',
  },
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
    (Story, { globals }) => {
      const currentLocale = (globals.locale as string) || 'en';
      const [messages, setMessages] = useState<
        Record<string, Record<string, string>>
      >({});
      const currentLocaleData = messages[currentLocale];

      useEffect(() => {
        async function loadLocaleData() {
          const { default: localeFile } = (await import(
            `@/mastodon/locales/${currentLocale}.json`
          )) as { default: LocaleData['messages'] };
          setMessages((prevLocales) => ({
            ...prevLocales,
            [currentLocale]: localeFile,
          }));
        }
        if (!currentLocaleData) {
          void loadLocaleData();
        }
      }, [currentLocale, currentLocaleData]);

      return (
        <IntlProvider
          locale={currentLocale}
          messages={currentLocaleData}
          textComponent='span'
        >
          <Story />
        </IntlProvider>
      );
    },
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

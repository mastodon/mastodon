import { useEffect, useState } from 'react';

import { IntlProvider } from 'react-intl';

import { MemoryRouter, Route } from 'react-router';

import { configureStore } from '@reduxjs/toolkit';
import { Provider } from 'react-redux';

import type { Preview } from '@storybook/react-vite';
import { initialize, mswLoader } from 'msw-storybook-addon';
import { action } from 'storybook/actions';

import {
  importCustomEmojiData,
  importLegacyShortcodes,
  importEmojiData,
} from '@/mastodon/features/emoji/loader';
import type { LocaleData } from '@/mastodon/locales';
import { reducerWithInitialState } from '@/mastodon/reducers';
import { defaultMiddleware } from '@/mastodon/store/store';
import { mockHandlers, unhandledRequestHandler } from '@/testing/api';

// If you want to run the dark theme during development,
// you can change the below to `/application.scss`
import '../app/javascript/styles/mastodon-light.scss';
import './styles.css';

const localeFiles = import.meta.glob('@/mastodon/locales/*.json', {
  query: { as: 'json' },
});

// Initialize MSW
initialize({
  onUnhandledRequest: unhandledRequestHandler,
});

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
    (Story, { parameters, globals, args }) => {
      // Get the locale from the global toolbar
      // and merge it with any parameters or args state.
      const { locale } = globals as { locale: string };
      const { state = {} } = parameters;
      const { state: argsState = {} } = args;

      const reducer = reducerWithInitialState(
        {
          meta: {
            locale,
          },
        },
        state as Record<string, unknown>,
        argsState as Record<string, unknown>,
      );

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
    (Story) => (
      <MemoryRouter>
        <Story />
        <Route
          path='*'
          // eslint-disable-next-line react/jsx-no-bind
          render={({ location }) => {
            if (location.pathname !== '/') {
              action(`route change to ${location.pathname}`)(location);
            }
            return null;
          }}
        />
      </MemoryRouter>
    ),
  ],
  loaders: [
    mswLoader,
    importCustomEmojiData,
    importLegacyShortcodes,
    ({ globals: { locale } }) => importEmojiData(locale as string),
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

    docs: {},

    msw: {
      handlers: mockHandlers,
    },
  },
};

export default preview;

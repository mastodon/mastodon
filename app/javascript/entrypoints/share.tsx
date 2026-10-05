import { createRoot } from 'react-dom/client';

import { Provider } from 'react-redux';

import { fetchServer } from '@/mastodon/actions/server';
import { hydrateStore } from '@/mastodon/actions/store';
import { Router } from '@/mastodon/components/router';
import { initializeEmoji } from '@/mastodon/features/emoji';
import { Compose } from '@/mastodon/features/standalone/compose';
import { initialState } from '@/mastodon/initial_state';
import { IntlProvider } from '@/mastodon/locales';
import { loadPolyfills } from '@/mastodon/polyfills';
import ready from '@/mastodon/ready';
import { store } from '@/mastodon/store';

async function loaded() {
  const mountNode = document.getElementById('mastodon-compose');

  if (!mountNode) {
    return;
  }

  if (initialState) {
    store.dispatch(hydrateStore(initialState));
  }

  await store.dispatch(fetchServer());
  await initializeEmoji();

  const root = createRoot(mountNode);

  root.render(
    <IntlProvider>
      <Provider store={store}>
        <Router>
          <Compose />
        </Router>
      </Provider>
    </IntlProvider>,
  );
}

function main() {
  ready(loaded).catch((error: unknown) => {
    console.error(error);
  });
}

loadPolyfills()
  .then(main)
  .catch((error: unknown) => {
    console.error(error);
  });

import { Provider } from 'react-redux';

import { fetchCustomEmojis } from 'mastodon/actions/custom_emojis';
import { hydrateStore } from 'mastodon/actions/store';
import { Router } from 'mastodon/components/router';
import Compose from 'mastodon/features/standalone/compose';
import initialState from 'mastodon/initial_state';
import { IntlProvider } from 'mastodon/locales';
import { store } from 'mastodon/store';

if (initialState) {
  store.dispatch(hydrateStore(initialState));
}

store.dispatch(fetchCustomEmojis());

const ComposeContainer = () => (
  <IntlProvider>
    <Provider store={store}>
      <Router>
        <Compose />
      </Router>
    </Provider>
  </IntlProvider>
);

export default ComposeContainer;

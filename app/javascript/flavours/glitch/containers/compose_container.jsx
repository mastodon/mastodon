import { Provider } from 'react-redux';

import { fetchCustomEmojis } from 'flavours/glitch/actions/custom_emojis';
import { hydrateStore } from 'flavours/glitch/actions/store';
import { Router } from 'flavours/glitch/components/router';
import Compose from 'flavours/glitch/features/standalone/compose';
import initialState from 'flavours/glitch/initial_state';
import { IntlProvider } from 'flavours/glitch/locales';
import { store } from 'flavours/glitch/store';

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

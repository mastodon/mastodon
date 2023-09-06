import { PureComponent } from 'react';

import { Provider } from 'react-redux';

import { fetchCustomEmojis } from 'flavours/glitch/actions/custom_emojis';
import { hydrateStore } from 'flavours/glitch/actions/store';
import Compose from 'flavours/glitch/features/standalone/compose';
import initialState from 'flavours/glitch/initial_state';
import { IntlProvider } from 'flavours/glitch/locales';
import { store } from 'flavours/glitch/store';

if (initialState) {
  store.dispatch(hydrateStore(initialState));
}

store.dispatch(fetchCustomEmojis());

export default class ComposeContainer extends PureComponent {

  render () {
    return (
      <IntlProvider>
        <Provider store={store}>
          <Compose />
        </Provider>
      </IntlProvider>
    );
  }

}

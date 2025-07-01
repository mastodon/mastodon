import { PureComponent } from 'react';

import { Provider } from 'react-redux';

import { fetchCustomEmojis } from '../actions/custom_emojis';
import { fetchServer } from '../actions/server';
import { hydrateStore } from '../actions/store';
import Compose from '../features/standalone/compose';
import initialState from '../initial_state';
import { IntlProvider } from '../locales';
import { store } from '../store';

if (initialState) {
  store.dispatch(hydrateStore(initialState));
}

store.dispatch(fetchCustomEmojis());
store.dispatch(fetchServer());

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

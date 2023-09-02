import React from 'react';

import { IntlProvider } from 'react-intl';

import { Provider } from 'react-redux';

import type { RenderOptions } from '@testing-library/react';
import { render as testRender } from '@testing-library/react';

import { createStore } from 'mastodon/store';

export const render = (node: React.ReactNode, opts?: RenderOptions) => {
  const store = createStore();
  return testRender(
    <Provider store={store}>
      <IntlProvider locale='unknown' messages={{}} textComponent='span'>
        {node}
      </IntlProvider>
    </Provider>,
    opts,
  );
};

export { fireEvent } from '@testing-library/react';

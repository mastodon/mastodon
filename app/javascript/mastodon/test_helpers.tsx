import PropTypes from 'prop-types';
import type { PropsWithChildren } from 'react';
import { Component } from 'react';

import { IntlProvider } from 'react-intl';

import { MemoryRouter } from 'react-router';

// eslint-disable-next-line import/no-extraneous-dependencies
import { render as rtlRender } from '@testing-library/react';

class FakeIdentityWrapper extends Component<
  PropsWithChildren<{ signedIn: boolean }>
> {
  static childContextTypes = {
    identity: PropTypes.shape({
      signedIn: PropTypes.bool.isRequired,
      accountId: PropTypes.string,
      disabledAccountId: PropTypes.string,
      accessToken: PropTypes.string,
    }).isRequired,
  };

  getChildContext() {
    return {
      identity: {
        signedIn: this.props.signedIn,
        accountId: '123',
        accessToken: 'test-access-token',
      },
    };
  }

  render() {
    return this.props.children;
  }
}

function render(
  ui: React.ReactElement,
  { locale = 'en', signedIn = true, ...renderOptions } = {},
) {
  const Wrapper = (props: { children: React.ReactElement }) => {
    return (
      <MemoryRouter>
        <IntlProvider locale={locale}>
          <FakeIdentityWrapper signedIn={signedIn}>
            {props.children}
          </FakeIdentityWrapper>
        </IntlProvider>
      </MemoryRouter>
    );
  };
  return rtlRender(ui, { wrapper: Wrapper, ...renderOptions });
}

// re-export everything
// eslint-disable-next-line import/no-extraneous-dependencies
export * from '@testing-library/react';

// override render method
export { render };

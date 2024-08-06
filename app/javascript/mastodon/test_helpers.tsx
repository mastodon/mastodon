import { IntlProvider } from 'react-intl';

import { MemoryRouter } from 'react-router';

import type { RenderOptions } from '@testing-library/react';
// eslint-disable-next-line import/no-extraneous-dependencies
import { render as rtlRender } from '@testing-library/react';

import { IdentityContext } from './identity_context';

function render(
  ui: React.ReactElement,
  {
    locale = 'en',
    signedIn = true,
    ...renderOptions
  }: RenderOptions & { locale?: string; signedIn?: boolean } = {},
) {
  const fakeIdentity = {
    signedIn: signedIn,
    accountId: '123',
    disabledAccountId: undefined,
    permissions: 0,
  };

  const Wrapper = (props: { children: React.ReactNode }) => {
    return (
      <MemoryRouter>
        <IntlProvider locale={locale}>
          <IdentityContext.Provider value={fakeIdentity}>
            {props.children}
          </IdentityContext.Provider>
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

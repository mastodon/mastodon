import { createContext, useContext } from 'react';

import type { InitialState } from 'mastodon/initial_state';

export const createIdentityContextValue = (state: InitialState) => ({
  accessToken: state.meta.access_token,
  accountId: state.meta.me,
  disabledAccountId: state.meta.disabled_account_id,
  permissions: state.role ? state.role.permissions : 0,
  signedIn: !!state.meta.me,
});

export type IdentityContextValue = ReturnType<
  typeof createIdentityContextValue
>;

export const IdentityContext = createContext<IdentityContextValue | undefined>(
  undefined,
);

export const useIdentityContext = () => {
  const context = useContext(IdentityContext);

  if (!context) {
    throw new Error(
      'useIdentityContext called outside of provided IdentityContext.',
    );
  }

  return context;
};

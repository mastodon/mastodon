import { createContext, useContext } from 'react';

import type { InitialState } from 'mastodon/initial_state';

interface IdentityState {
  signedIn: boolean;
  accountId: string;
  disabledAccountId: string;
  accessToken: string;
  permissions: number;
}

export const IdentityContext = createContext<IdentityState>({
  signedIn: false,
  accountId: '',
  disabledAccountId: '',
  accessToken: '',
  permissions: 0,
});

export const createLegacyIdentityContext = (state: InitialState) => {
  return {
    signedIn: !!state.meta.me,
    accountId: state.meta.me,
    disabledAccountId: state.meta.disabled_account_id,
    accessToken: state.meta.access_token,
    permissions: state.role?.permissions ?? 0,
  };
};

export const useIdentityContext = (): IdentityState => {
  return useContext(IdentityContext);
};

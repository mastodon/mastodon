import { createAction } from '@reduxjs/toolkit';

import type { ApiAccountJSON } from 'mastodon/api_types/accounts';

export const revealAccount = createAction<{
  id: string;
}>('accounts/revealAccount');

export const importAccounts = createAction<{ accounts: ApiAccountJSON[] }>(
  'accounts/importAccounts',
);

export const followAccountSuccess = createAction(
  'accounts/followAccountSuccess',
  (args: { relationship: { id: string }; alreadyFollowing: boolean }) => ({
    payload: {
      ...args,
      skipLoading: true,
    },
  }),
);

export const unfollowAccountSuccess = createAction(
  'accounts/unfollowAccountSuccess',
  (args: {
    relationship: { id: string };
    statuses: unknown;
    alreadyFollowing?: boolean;
  }) => ({
    payload: {
      ...args,
      skipLoading: true,
    },
  }),
);

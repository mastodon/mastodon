import { createAction } from '@reduxjs/toolkit';

import type { ApiAccountJSON } from 'mastodon/api_types/accounts';
import type { ApiRelationshipJSON } from 'mastodon/api_types/relationships';

export const revealAccount = createAction<{
  id: string;
}>('accounts/revealAccount');

export const importAccounts = createAction<{ accounts: ApiAccountJSON[] }>(
  'accounts/importAccounts',
);

function actionWithSkipLoadingTrue<Args extends object>(args: Args) {
  return {
    payload: {
      ...args,
      skipLoading: true,
    },
  };
}

export const followAccountSuccess = createAction(
  'accounts/followAccountSuccess',
  actionWithSkipLoadingTrue<{
    relationship: ApiRelationshipJSON;
    alreadyFollowing: boolean;
  }>,
);

export const unfollowAccountSuccess = createAction(
  'accounts/unfollowAccountSuccess',
  actionWithSkipLoadingTrue<{
    relationship: ApiRelationshipJSON;
    statuses: unknown;
    alreadyFollowing?: boolean;
  }>,
);

export const authorizeFollowRequestSuccess = createAction<{ id: string }>(
  'accounts/followRequestAuthorizeSuccess',
);

export const rejectFollowRequestSuccess = createAction<{ id: string }>(
  'accounts/followRequestRejectSuccess',
);

export const followAccountRequest = createAction(
  'accounts/followRequest',
  actionWithSkipLoadingTrue<{ id: string; locked: boolean }>,
);

export const followAccountFail = createAction(
  'accounts/followFail',
  actionWithSkipLoadingTrue<{ id: string; error: string; locked: boolean }>,
);

export const unfollowAccountRequest = createAction(
  'accounts/unfollowRequest',
  actionWithSkipLoadingTrue<{ id: string }>,
);

export const unfollowAccountFail = createAction(
  'accounts/unfollowFail',
  actionWithSkipLoadingTrue<{ id: string; error: string }>,
);

export const blockAccountSuccess = createAction<{
  relationship: ApiRelationshipJSON;
  statuses: unknown;
}>('accounts/blockSuccess');

export const unblockAccountSuccess = createAction<{
  relationship: ApiRelationshipJSON;
}>('accounts/unblockSuccess');

export const muteAccountSuccess = createAction<{
  relationship: ApiRelationshipJSON;
  statuses: unknown;
}>('accounts/muteSuccess');

export const unmuteAccountSuccess = createAction<{
  relationship: ApiRelationshipJSON;
}>('accounts/unmuteSuccess');

export const pinAccountSuccess = createAction<{
  relationship: ApiRelationshipJSON;
}>('accounts/pinSuccess');

export const unpinAccountSuccess = createAction<{
  relationship: ApiRelationshipJSON;
}>('accounts/unpinSuccess');

export const fetchRelationshipsSuccess = createAction(
  'relationships/fetchSuccess',
  actionWithSkipLoadingTrue<{ relationships: ApiRelationshipJSON[] }>,
);

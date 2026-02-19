import { createAction } from '@reduxjs/toolkit';

import {
  apiRemoveAccountFromFollowers,
  apiGetEndorsedAccounts,
} from 'mastodon/api/accounts';
import type { ApiRelationshipJSON } from 'mastodon/api_types/relationships';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

import { importFetchedAccounts } from './importer';

export const revealAccount = createAction<{
  id: string;
}>('accounts/revealAccount');

function actionWithSkipLoadingTrue<Args extends object>(args: Args) {
  return {
    payload: {
      ...args,
      skipLoading: true,
    },
  };
}

export const followAccountSuccess = createAction(
  'accounts/followAccount/SUCCESS',
  actionWithSkipLoadingTrue<{
    relationship: ApiRelationshipJSON;
    alreadyFollowing: boolean;
  }>,
);

export const unfollowAccountSuccess = createAction(
  'accounts/unfollowAccount/SUCCESS',
  actionWithSkipLoadingTrue<{
    relationship: ApiRelationshipJSON;
    statuses: unknown;
    alreadyFollowing?: boolean;
  }>,
);

export const authorizeFollowRequestSuccess = createAction<{ id: string }>(
  'accounts/followRequestAuthorize/SUCCESS',
);

export const rejectFollowRequestSuccess = createAction<{ id: string }>(
  'accounts/followRequestReject/SUCCESS',
);

export const followAccountRequest = createAction(
  'accounts/follow/REQUEST',
  actionWithSkipLoadingTrue<{ id: string; locked: boolean }>,
);

export const followAccountFail = createAction(
  'accounts/follow/FAIL',
  actionWithSkipLoadingTrue<{ id: string; error: string; locked: boolean }>,
);

export const unfollowAccountRequest = createAction(
  'accounts/unfollow/REQUEST',
  actionWithSkipLoadingTrue<{ id: string }>,
);

export const unfollowAccountFail = createAction(
  'accounts/unfollow/FAIL',
  actionWithSkipLoadingTrue<{ id: string; error: string }>,
);

export const blockAccountSuccess = createAction<{
  relationship: ApiRelationshipJSON;
  statuses: unknown;
}>('accounts/block/SUCCESS');

export const unblockAccountSuccess = createAction<{
  relationship: ApiRelationshipJSON;
}>('accounts/unblock/SUCCESS');

export const muteAccountSuccess = createAction<{
  relationship: ApiRelationshipJSON;
  statuses: unknown;
}>('accounts/mute/SUCCESS');

export const unmuteAccountSuccess = createAction<{
  relationship: ApiRelationshipJSON;
}>('accounts/unmute/SUCCESS');

export const pinAccountSuccess = createAction<{
  relationship: ApiRelationshipJSON;
}>('accounts/pin/SUCCESS');

export const unpinAccountSuccess = createAction<{
  relationship: ApiRelationshipJSON;
}>('accounts/unpin/SUCCESS');

export const fetchRelationshipsSuccess = createAction(
  'relationships/fetch/SUCCESS',
  actionWithSkipLoadingTrue<{ relationships: ApiRelationshipJSON[] }>,
);

export const removeAccountFromFollowers = createDataLoadingThunk(
  'accounts/remove_from_followers',
  ({ accountId }: { accountId: string }) =>
    apiRemoveAccountFromFollowers(accountId),
  (relationship) => ({ relationship }),
);

export const fetchEndorsedAccounts = createDataLoadingThunk(
  'accounts/endorsements',
  ({ accountId }: { accountId: string }) => apiGetEndorsedAccounts(accountId),
  (data, { dispatch }) => {
    dispatch(importFetchedAccounts(data));
    return data;
  },
);

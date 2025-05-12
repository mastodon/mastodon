import { createReducer } from '@reduxjs/toolkit';

import { fetchAccountsFamiliarFollowers } from '../actions/accounts_familiar_followers';

const initialState: Record<string, string[]> = {};

export const accountsFamiliarFollowersReducer = createReducer(
  initialState,
  (builder) => {
    builder.addCase(
      fetchAccountsFamiliarFollowers.fulfilled,
      (state, { payload }) => {
        if (payload) {
          state[payload.id] = payload.accountIds;
        }
      },
    );
  },
);

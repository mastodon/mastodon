import { createReducer } from '@reduxjs/toolkit';

import { fetchDonateData, setDonateSeed } from '../actions/donate';
import type { DonateServerResponse } from '../api_types/donate';

interface DonateState {
  apiResponse?: DonateServerResponse;
  nextPoll?: number;
  isFetching: boolean;
  seed?: number;
}

const initialState: DonateState = {
  isFetching: false,
};

export const donateReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(setDonateSeed, (state, action) => {
      state.seed = action.payload;
    })
    .addCase(fetchDonateData.pending, (state) => {
      state.isFetching = true;
    })
    .addCase(fetchDonateData.rejected, (state) => {
      state.isFetching = false;
    })
    .addCase(fetchDonateData.fulfilled, (state, action) => {
      if (action.payload) {
        state.apiResponse = action.payload;
      }
      // If we have data, poll in four hours, otherwise try again in one hour.
      state.nextPoll = Date.now() + 1000 * 60 * 60 * (action.payload ? 4 : 1);
      state.isFetching = false;
    });
});

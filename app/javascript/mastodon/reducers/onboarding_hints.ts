import { createReducer } from '@reduxjs/toolkit';

import {
  setActiveOnboardingHint,
  clearActiveOnboardingHint,
} from 'mastodon/actions/onboarding_hints';

interface State {
  activeOnboardingHintId: string | null;
}

const initialState: State = {
  activeOnboardingHintId: null,
};

/**
 * Ensures that only a single onboarding hint is displayed at a time
 */
export const onboardingHintsReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(setActiveOnboardingHint, (state, action) => {
      state.activeOnboardingHintId ??= action.payload;
    })
    .addCase(clearActiveOnboardingHint, (state, action) => {
      if (state.activeOnboardingHintId === action.payload) {
        state.activeOnboardingHintId = null;
      }
    });
});

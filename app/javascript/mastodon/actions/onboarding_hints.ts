import { createAction } from '@reduxjs/toolkit';

export const setActiveOnboardingHint = createAction<string>(
  'onboarding_hints/set',
);

export const clearActiveOnboardingHint = createAction<string>(
  'onboarding_hints/clear',
);

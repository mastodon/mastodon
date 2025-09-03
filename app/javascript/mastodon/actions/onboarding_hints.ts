import { createAction } from '@reduxjs/toolkit';

export const setActiveOnboardingHint = createAction<string>(
  'onboarding_hints/set',
);

export const clearActiveOnboardingHint = createAction('onboarding_hints/clear');

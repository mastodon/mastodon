export const APP_FOCUS   = 'APP_FOCUS';
export const APP_UNFOCUS = 'APP_UNFOCUS';

export const focusApp = () => ({
  type: APP_FOCUS,
});

export const unfocusApp = () => ({
  type: APP_UNFOCUS,
});

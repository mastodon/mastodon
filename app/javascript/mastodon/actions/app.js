export const APP_FOCUS   = 'APP_FOCUS';
export const APP_UNFOCUS = 'APP_UNFOCUS';

export const focusApp = () => ({
  type: APP_FOCUS,
});

export const unfocusApp = () => ({
  type: APP_UNFOCUS,
});

export const APP_LAYOUT_CHANGE = 'APP_LAYOUT_CHANGE';

export const changeLayout = layout => ({
  type: APP_LAYOUT_CHANGE,
  layout,
});

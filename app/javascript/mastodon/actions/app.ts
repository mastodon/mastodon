import { createAction } from '@reduxjs/toolkit';

export const focusApp = createAction('APP_FOCUS');
export const unfocusApp = createAction('APP_UNFOCUS');

type ChangeLayoutPayload = {
  layout: 'mobile' | 'single-column' | 'multi-column';
};
export const changeLayout =
  createAction<ChangeLayoutPayload>('APP_LAYOUT_CHANGE');

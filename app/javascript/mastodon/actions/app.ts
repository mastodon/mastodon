import { createAction } from '@reduxjs/toolkit';

import type { LayoutType } from '../is_mobile';

export const focusApp = createAction('APP_FOCUS');
export const unfocusApp = createAction('APP_UNFOCUS');

interface ChangeLayoutPayload {
  layout: LayoutType;
}
export const changeLayout =
  createAction<ChangeLayoutPayload>('APP_LAYOUT_CHANGE');

import { createAction } from '@reduxjs/toolkit';

import type { LayoutType } from '../is_mobile';

interface ChangeLayoutPayload {
  layout: LayoutType;
}
export const changeLayout =
  createAction<ChangeLayoutPayload>('APP_LAYOUT_CHANGE');

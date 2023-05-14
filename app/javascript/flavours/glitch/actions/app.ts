import { createAction } from '@reduxjs/toolkit';
import type { LayoutType } from '../is_mobile';

type ChangeLayoutPayload = {
  layout: LayoutType;
};
export const changeLayout =
  createAction<ChangeLayoutPayload>('APP_LAYOUT_CHANGE');

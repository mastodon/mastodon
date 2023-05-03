import { createAction } from '@reduxjs/toolkit';

type ChangeLayoutPayload = {
  layout: 'mobile' | 'single-column' | 'multi-column';
};
export const changeLayout =
  createAction<ChangeLayoutPayload>('APP_LAYOUT_CHANGE');

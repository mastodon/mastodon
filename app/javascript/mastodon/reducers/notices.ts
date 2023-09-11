import { createReducer } from '@reduxjs/toolkit';

import type { ApiNoticeJSON } from '../actions/notices';
import { fetchNotices, dismissNotice } from '../actions/notices';

const initialState: ApiNoticeJSON[] = [];

export const noticesReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(
      fetchNotices.fulfilled,
      (_state, { payload: { notices } }) => notices,
    )
    .addCase(dismissNotice.fulfilled, () => []);
});

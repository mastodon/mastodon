import { createReducer } from '@reduxjs/toolkit';

import { submitMarkersAction } from 'mastodon/actions/markers';

const initialState = {
  home: '0',
  notifications: '0',
};

export const markersReducer = createReducer(initialState, (builder) => {
  builder.addCase(
    submitMarkersAction.fulfilled,
    (state, { payload: { home, notifications } }) => {
      if (home) state.home = home;
      if (notifications) state.notifications = notifications;
    },
  );
});

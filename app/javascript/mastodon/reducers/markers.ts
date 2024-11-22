import { createReducer } from '@reduxjs/toolkit';

import { submitMarkersAction, fetchMarkers } from 'mastodon/actions/markers';
import { compareId } from 'mastodon/compare_id';

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
  builder.addCase(
    fetchMarkers.fulfilled,
    (
      state,
      {
        payload: {
          markers: { home, notifications },
        },
      },
    ) => {
      if (home && compareId(home.last_read_id, state.home) > 0)
        state.home = home.last_read_id;
      if (
        notifications &&
        compareId(notifications.last_read_id, state.notifications) > 0
      )
        state.notifications = notifications.last_read_id;
    },
  );
});

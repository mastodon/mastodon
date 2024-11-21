import { createAppAsyncThunk } from 'mastodon/store';

import { fetchNotifications } from './notification_groups';

export const initializeNotifications = createAppAsyncThunk(
  'notifications/initialize',
  (_, { dispatch }) => {
    void dispatch(fetchNotifications());
  },
);

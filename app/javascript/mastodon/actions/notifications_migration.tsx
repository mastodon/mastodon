import { createAppAsyncThunk } from 'mastodon/store';

import { fetchNotifications } from './notification_groups';
import { expandNotifications } from './notifications';

export const initializeNotifications = createAppAsyncThunk(
  'notifications/initialize',
  (_, { dispatch, getState }) => {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access
    const enableBeta = getState().settings.getIn(
      ['notifications', 'groupingBeta'],
      false,
    ) as boolean;

    if (enableBeta) void dispatch(fetchNotifications());
    else void dispatch(expandNotifications({}));
  },
);

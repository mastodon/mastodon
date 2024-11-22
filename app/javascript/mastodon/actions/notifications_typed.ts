import { createAction } from '@reduxjs/toolkit';

import type { ApiNotificationJSON } from 'mastodon/api_types/notifications';

export const notificationsUpdate = createAction(
  'notifications/update',
  ({
    playSound,
    ...args
  }: {
    notification: ApiNotificationJSON;
    usePendingItems: boolean;
    playSound: boolean;
  }) => ({
    payload: args,
    meta: { sound: playSound ? 'boop' : undefined },
  }),
);

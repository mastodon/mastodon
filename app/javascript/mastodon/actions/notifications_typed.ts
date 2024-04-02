import { createAction } from '@reduxjs/toolkit';

import type { ApiAccountJSON } from '../api_types/accounts';
// To be replaced once ApiNotificationJSON type exists
interface FakeApiNotificationJSON {
  type: string;
  account: ApiAccountJSON;
}

export const notificationsUpdate = createAction(
  'notifications/update',
  ({
    playSound,
    ...args
  }: {
    notification: FakeApiNotificationJSON;
    usePendingItems: boolean;
    playSound: boolean;
  }) => ({
    payload: args,
    meta: { sound: playSound ? 'boop' : undefined },
  }),
);

import { createAction } from '@reduxjs/toolkit';

import type { ApiAccountJSON } from 'mastodon/api_types/accounts';

export const importAccounts = createAction<{ accounts: ApiAccountJSON[] }>(
  'accounts/importAccounts',
);

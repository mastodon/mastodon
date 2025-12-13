import { createAction } from '@reduxjs/toolkit';

import type { Poll } from 'mastodon/models/poll';

export const importPolls = createAction<{ polls: Poll[] }>(
  'poll/importMultiple',
);

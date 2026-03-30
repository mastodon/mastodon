import type { RecordOf } from 'immutable';

import type { ApiPreviewCardJSON } from 'mastodon/api_types/statuses';

export type { StatusVisibility } from 'mastodon/api_types/statuses';

// Temporary until we type it correctly
export type Status = Immutable.Map<string, unknown>;

export type Card = RecordOf<ApiPreviewCardJSON>;

export type MediaAttachment = Immutable.Map<string, unknown>;

import type { ShallowApiAccountJSON } from 'mastodon/api_types/accounts';
import type { ApiNotificationGroupJSON } from 'mastodon/api_types/notifications';
import type { ShallowApiStatusJSON } from 'mastodon/api_types/statuses';

export interface ApiGenericJSON {
  statuses: ShallowApiStatusJSON[];
  accounts: ShallowApiAccountJSON[];
  notification_groups: ApiNotificationGroupJSON[];
}

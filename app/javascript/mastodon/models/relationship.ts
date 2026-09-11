import type { RecordOf } from 'immutable';
import { Record } from 'immutable';

import type { ApiRelationshipJSON } from 'mastodon/api_types/relationships';

type RelationshipShape = Required<ApiRelationshipJSON>; // no changes from server shape
export type Relationship = RecordOf<RelationshipShape>;

const RelationshipFactory = Record<RelationshipShape>({
  blocked_by: false,
  blocking: false,
  domain_blocking: false,
  endorsed: false,
  followed_by: false,
  following: false,
  id: '',
  languages: null,
  muting: false,
  muting_notifications: false,
  muting_expires_at: null,
  note: '',
  notifying: false,
  requested_by: false,
  requested: false,
  showing_reblogs: false,
});

export function createRelationship(attributes: Partial<RelationshipShape>) {
  return RelationshipFactory(attributes);
}

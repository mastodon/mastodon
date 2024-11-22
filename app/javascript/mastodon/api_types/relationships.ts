// See app/serializers/rest/relationship_serializer.rb
export interface ApiRelationshipJSON {
  blocked_by: boolean;
  blocking: boolean;
  domain_blocking: boolean;
  endorsed: boolean;
  followed_by: boolean;
  following: boolean;
  id: string;
  languages: string[] | null;
  muting_notifications: boolean;
  muting: boolean;
  note: string;
  notifying: boolean;
  requested_by: boolean;
  requested: boolean;
  showing_reblogs: boolean;
}

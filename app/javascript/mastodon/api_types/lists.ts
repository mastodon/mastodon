// See app/serializers/rest/list_serializer.rb

export type RepliesPolicyType = 'list' | 'followed' | 'none';

export interface ApiListJSON {
  id: string;
  title: string;
  exclusive: boolean;
  replies_policy: RepliesPolicyType;
}

object @status

extends 'api/v1/statuses/_show'

node(:favourited, if: proc { !current_account.nil? }) { |status| defined?(@favourites_map) ? @favourites_map[status.id]         : current_account.favourited?(status) }
node(:reblogged,  if: proc { !current_account.nil? }) { |status| defined?(@reblogs_map)    ? @reblogs_map[status.id]            : current_account.reblogged?(status) }
node(:muted,      if: proc { !current_account.nil? }) { |status| defined?(@mutes_map)      ? @mutes_map[status.conversation_id] : current_account.muting_conversation?(status.conversation) }

child reblog: :reblog do
  extends 'api/v1/statuses/_show'

  node(:favourited, if: proc { !current_account.nil? }) { |status| defined?(@favourites_map) ? @favourites_map[status.id] : current_account.favourited?(status) }
  node(:reblogged,  if: proc { !current_account.nil? }) { |status| defined?(@reblogs_map)    ? @reblogs_map[status.id]    : current_account.reblogged?(status) }
  node(:muted,      if: proc { !current_account.nil? }) { false }
end

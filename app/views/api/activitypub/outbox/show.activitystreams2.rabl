extends 'activitypub/types/ordered_collection_page.activitystreams2.rabl'

object @account

node(:items) do
  @statuses.map do |status|
    api_activitypub_status_url(status)
  end
end

node(:totalItems) { @statuses.count }
node(:current)    { api_activitypub_outbox_url }
node(:next)       { @next_path }
node(:prev)       { @prev_path }

node(:name)       { |account| "#{account_name account}'s Outbox"  }
node(:summary)    { |account| "A collection of all activities from user #{account_name account}." }
node(:updated) do |account|
  times = @statuses.map { |status| status.updated_at.to_time }
  times = times.concat([account.created_at.to_time])
  times.max.xmlschema
end

if @paginated
  extends 'activitypub/types/ordered_collection_page.activitystreams2.rabl'
else
  extends 'activitypub/types/ordered_collection.activitystreams2.rabl'
end

object @account

node(:items) do
  @statuses.map { |status| api_activitypub_status_url(status) }
end

node(:totalItems) { @statuses.count }
node(:next)       { @next_path } if @next_path
node(:prev)       { @prev_path } if @prev_path

node(:name)       { |account| t('activitypub.outbox.name', account_name: account_name(account)) }
node(:summary)    { |account| t('activitypub.outbox.summary', account_name: account_name(account)) }
node(:updated) do |account|
  times = @statuses.map { |status| status.updated_at.to_time }
  times << account.created_at.to_time
  times.max.xmlschema
end

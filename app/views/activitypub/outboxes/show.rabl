object @account

node(:'@context') { 'https://www.w3.org/ns/activitystreams' }
node(:type) { 'OrderedCollection' }
node(:totalItems, &:statuses_count)
node(:current) { |account| account_outbox_url(account) }

child({ @statuses => :orderedItems }, object_root: false) do
  extends 'activitypub/outboxes/create'
end

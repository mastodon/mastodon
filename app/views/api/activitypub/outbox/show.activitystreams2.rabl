extends 'activitypub/types/ordered_collection.activitystreams2.rabl'

object @account

node(:totalItems) { @statuses.count }
node(:current)    { @first_page_url } if @first_page_url
node(:first)      { @first_page_url } if @first_page_url
node(:last)       { @last_page_url } if @last_page_url

node(:name)       { |account| t('activitypub.outbox.name', account_name: account_name(account)) }
node(:summary)    { |account| t('activitypub.outbox.summary', account_name: account_name(account)) }
node(:updated)    { |account| (@statuses.empty? ? account.created_at.to_time : @statuses.first.updated_at.to_time).xmlschema }

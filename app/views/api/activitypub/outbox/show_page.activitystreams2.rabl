extends 'activitypub/types/ordered_collection_page.activitystreams2.rabl'

object @account

node(:items) do
  @statuses.map { |status| api_activitypub_status_url(status) }
end

node(:next)       { @next_page_url } if @next_page_url
node(:prev)       { @prev_page_url } if @prev_page_url
node(:current)    { @first_page_url } if @first_page_url
node(:first)      { @first_page_url } if @first_page_url
node(:last)       { @last_page_url } if @last_page_url
node(:partOf)     { @part_of_url } if @part_of_url

node(:updated)    { |account| (@statuses.empty? ? account.created_at.to_time : @statuses.first.updated_at.to_time).xmlschema }

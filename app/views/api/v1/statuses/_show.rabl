attributes :id, :created_at, :in_reply_to_id

node(:uri)              { |status| TagManager.instance.uri_for(status) }
node(:content)          { |status| Formatter.instance.format(status) }
node(:url)              { |status| TagManager.instance.url_for(status) }
node(:reblogs_count)    { |status| status.reblogs_count }
node(:favourites_count) { |status| status.favourites_count }

child :account do
  extends 'api/v1/accounts/show'
end

child :media_attachments, object_root: false do
  extends 'api/v1/statuses/_media'
end

child :mentions, object_root: false do
  extends 'api/v1/statuses/_mention'
end

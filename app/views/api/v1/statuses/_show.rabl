attributes :id, :created_at, :in_reply_to_id, :in_reply_to_account_id, :sensitive, :visibility

node(:uri)              { |status| TagManager.instance.uri_for(status) }
node(:content)          { |status| Formatter.instance.format(status) }
node(:spoiler_text)     { |status| Formatter.instance.format(status, :spoiler_text, false) }
node(:url)              { |status| TagManager.instance.url_for(status) }
node(:reblogs_count)    { |status| defined?(@reblogs_counts_map)    ? (@reblogs_counts_map[status.id]    || 0) : status.reblogs_count }
node(:favourites_count) { |status| defined?(@favourites_counts_map) ? (@favourites_counts_map[status.id] || 0) : status.favourites_count }

child :application do
  extends 'api/v1/apps/show'
end

child :account do
  extends 'api/v1/accounts/show'
end

child :media_attachments, object_root: false do
  extends 'api/v1/statuses/_media'
end

child :mentions, object_root: false do
  extends 'api/v1/statuses/_mention'
end

child :tags, object_root: false do
  extends 'api/v1/statuses/_tags'
end

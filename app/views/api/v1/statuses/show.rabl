object @status
attributes :id, :created_at, :in_reply_to_id

node(:uri)              { |status| TagManager.instance.uri_for(status) }
node(:content)          { |status| Formatter.instance.format(status) }
node(:url)              { |status| TagManager.instance.url_for(status) }
node(:reblogs_count)    { |status| status.reblogs_count }
node(:favourites_count) { |status| status.favourites_count }
node(:favourited, if: proc { !current_account.nil? }) { |status| defined?(@favourites_map) ? !!@favourites_map[status.id] : current_account.favourited?(status) }
node(:reblogged,  if: proc { !current_account.nil? }) { |status| defined?(@reblogs_map)    ? !!@reblogs_map[status.id]    : current_account.reblogged?(status) }

child :reblog => :reblog do
  extends('api/v1/statuses/show')
end

child :account do
  extends('api/v1/accounts/show')
end

child :media_attachments, object_root: false do
  attributes :id, :remote_url, :type

  node(:url)         { |media| full_asset_url(media.file.url) }
  node(:preview_url) { |media| full_asset_url(media.file.url(:small)) }
end

child :mentions, object_root: false do
  node(:url)  { |mention| TagManager.instance.url_for(mention.account) }
  node(:acct) { |mention| mention.account.acct }
  node(:id)   { |mention| mention.account_id }
end

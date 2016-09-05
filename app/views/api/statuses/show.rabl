object @status
attributes :id, :created_at, :in_reply_to_id

node(:uri)              { |status| uri_for_target(status) }
node(:content)          { |status| content_for_status(status) }
node(:url)              { |status| url_for_target(status) }
node(:reblogs_count)    { |status| status.reblogs_count }
node(:favourites_count) { |status| status.favourites_count }
node(:favourited)       { |status| current_account.favourited?(status) }
node(:reblogged)        { |status| current_account.reblogged?(status) }

child :reblog => :reblog do
  extends('api/statuses/show')
end

child :account do
  extends('api/accounts/show')
end

child :media_attachments, object_root: false do
  attributes :id, :remote_url

  node(:url) { |media| full_asset_url(media.file.url) }
  node(:preview_url) { |media| full_asset_url(media.file.url(:small)) }
end

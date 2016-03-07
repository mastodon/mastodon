object @status
attributes :id, :created_at, :in_reply_to_id

node(:uri)        { |status| uri_for_target(status) }
node(:content)    { |status| status.local? ? linkify(status) : status.content }
node(:url)        { |status| url_for_target(status) }
node(:reblogs)    { |status| status.reblogs.count }
node(:favourites) { |status| status.favourites.count }
node(:favourited) { |status| current_user.account.favourited?(status) }
node(:reblogged)  { |status| current_user.account.reblogged?(status) }

child :reblog => :reblog do
  extends('api/statuses/show')
end

child :account do
  extends('api/accounts/show')
end

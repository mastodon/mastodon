object @search

child accounts: :accounts do
  extends 'api/v1/accounts/show'
end

node(:hashtags) do |search|
  search.hashtags.map(&:name)
end

child statuses: :statuses do
  extends 'api/v1/statuses/show'
end

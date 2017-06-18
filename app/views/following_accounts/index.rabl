object @account

node(:'@context') { 'https://www.w3.org/ns/activitystreams' }
node(:type) { 'OrderedCollection' }
node(:totalItems, &:following_count)
node(:current) { |account| account_following_index_url(account) }
node(:orderedItems) { @follows.map { |a| TagManager.instance.uri_for(a) } }

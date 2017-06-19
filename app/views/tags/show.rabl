object @tag

node(:'@context') { 'https://www.w3.org/ns/activitystreams' }
node(:type) { 'OrderedCollection' }
node(:current) { |tag| tag_url(tag) }
node(:orderedItems) { @statuses.map { |s| ActivityPub::TagManager.instance.uri_for(s) } }

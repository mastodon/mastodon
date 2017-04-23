extends 'activitypub/types/ordered_collection.activitystreams2.rabl'

node(:type)     { 'OrderedCollectionPage' }
node(:current)  { request.original_url }

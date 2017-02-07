extends 'activitypub/base.activitystreams2.rabl'

node(:id) { request.original_url }

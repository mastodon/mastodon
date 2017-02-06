extends 'activitypub/base.rabl'

node(:id) { request.original_url }

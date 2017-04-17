extends 'activitypub/types/create.activitystreams2.rabl'
extends 'api/activitypub/activities/_show_status.activitystreams2.rabl'

object @status

node(:name)   { |status| "#{account_name status.account} created a note" }
node(:url)    { |status| TagManager.instance.url_for(status) }
node(:object) { |status| api_activitypub_note_url(status) }

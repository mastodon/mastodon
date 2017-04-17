extends 'activitypub/types/announce.activitystreams2.rabl'
extends 'api/activitypub/activities/_show_status.activitystreams2.rabl'

object @status

node(:name)   { |status| "#{account_name status.account} announced another activity." }
node(:url)    { |status| TagManager.instance.url_for(status) }
node(:object) { |status| api_activitypub_status_url(status.reblog_of_id) }

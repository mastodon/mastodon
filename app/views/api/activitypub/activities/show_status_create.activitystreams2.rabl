extends 'activitypub/types/create.activitystreams2.rabl'
extends 'api/activitypub/activities/_show_status.activitystreams2.rabl'

object @status

node(:name)   { |status| t('activitypub.activity.create.name', account_name: account_name(status.account)) }
node(:url)    { |status| TagManager.instance.url_for(status) }
node(:object) { |status| api_activitypub_note_url(status) }

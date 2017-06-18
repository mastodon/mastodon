node(:id)     { |status| [TagManager.instance.url_for(status), '#create'].join }
node(:type)   { |status| status.reblog? ? 'Announce' : 'Create' }
node(:actor)  { |status| TagManager.instance.uri_for(status.account) }
node(:object) { |status| partial('activitypub/outboxes/note', object: status.proper) }

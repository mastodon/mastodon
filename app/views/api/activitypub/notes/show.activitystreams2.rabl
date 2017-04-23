extends 'activitypub/types/note.activitystreams2.rabl'

object @status

attributes :content

node(:name)         { |status| status.content }
node(:url)          { |status| TagManager.instance.url_for(status) }
node(:attributedTo) { |status| TagManager.instance.url_for(status.account) }
node(:inReplyTo)    { |status| api_activitypub_note_url(status.thread) } if @status.thread
node(:published)    { |status| status.created_at.to_time.xmlschema }

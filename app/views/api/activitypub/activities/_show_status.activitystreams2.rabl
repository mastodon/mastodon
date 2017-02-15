object @status

node(:actor)     { |status| TagManager.instance.url_for(status.account) }
node(:published) { |status| status.created_at.to_time.xmlschema }
node(:generator) { |status| "Mastodon #{status.application.name}" } if @status.application
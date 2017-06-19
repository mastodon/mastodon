node(:id) { |status| ActivityPub::TagManager.instance.uri_for(status) }
node(:type) { 'Note' }
node(:summary, if: :spoiler_text?, &:spoiler_text)
node(:content) { |status| Formatter.instance.format(status) }
node(:inReplyTo, if: :reply?) { |status| ActivityPub::TagManager.instance.uri_for(status.thread) }
node(:published) { |status| status.created_at.iso8601 }
node(:url) { |status| ActivityPub::TagManager.instance.url_for(status) }
node(:actor) { |status| ActivityPub::TagManager.instance.uri_for(status.account) }
node(:to) { |status| ActivityPub::TagManager.instance.to(status) }
node(:cc, if: :unlisted_visibility?) { ActivityPub::TagManager::COLLECTIONS[:public] }
node(:attachment, if: ->(status) { status.media_attachments.present? }) { |status| status.media_attachments.map { |media| partial('activitypub/outboxes/attachment', object: media) } }

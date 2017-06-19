node(:id) { |status| ActivityPub::TagManager.instance.uri_for(status) }
node(:type) { 'Note' }
node(:summary, if: :spoiler_text?, &:spoiler_text)
node(:content) { |status| Formatter.instance.format(status) }
node(:inReplyTo, if: :reply?) { |status| ActivityPub::TagManager.instance.uri_for(status.thread) }
node(:published) { |status| status.created_at.iso8601 }
node(:url) { |status| ActivityPub::TagManager.instance.url_for(status) }
node(:actor) { |status| ActivityPub::TagManager.instance.uri_for(status.account) }
node(:to) do |status|
  case status.visibility
  when 'public'
    'https://www.w3.org/ns/activitystreams#Public'
  when 'unlisted', 'private'
    account_followers_url(status.account)
  when 'direct'
    status.mentions.map { |mention| ActivityPub::TagManager.instance.uri_for(mention.account) }
  end
end

node(:cc, if: :unlisted_visibility?) { 'https://www.w3.org/ns/activitystreams#Public' }
node(:attachment, if: ->(status) { status.media_attachments.present? }) { |status| status.media_attachments.map { |media| partial('activitypub/outboxes/attachment', object: media) } }

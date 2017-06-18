object @account

node(:'@context') { 'https://www.w3.org/ns/activitystreams' }
node(:type) { 'OrderedCollection' }
node(:totalItems, &:statuses_count)
node(:current) { |account| account_outbox_url(account) }

child({ @statuses => :orderedItems }, object_root: false) do
  node(:id) { |status| TagManager.instance.url_for(status.proper) }
  node(:type) { 'Note' }
  node(:summary, if: ->(status) { status.proper.spoiler_text? }) { |status| status.proper.spoiler_text }
  node(:content) { |status| Formatter.instance.format(status) }
  node(:inReplyTo, if: ->(status) { status.proper.reply? }) { |status| TagManager.instance.url_for(status.proper.thread) }
  node(:published) { |status| status.created_at.iso8601 }
  node(:url) { |status| TagManager.instance.url_for(status.proper) }
  node(:to) { 'https://www.w3.org/ns/activitystreams#Public' }
  node(:attachment, if: ->(status) { status.proper.media_attachments.present? }) do |status|
    status.proper.media_attachments.map do |media|
      { type: 'Image', mediaType: media.file_content_type, url: full_asset_url(media.file.url(:original, false)) }
    end
  end
end

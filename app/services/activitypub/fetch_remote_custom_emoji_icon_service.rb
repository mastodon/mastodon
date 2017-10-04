# frozen_string_literal: true

class ActivityPub::FetchRemoteCustomEmojiIconService < BaseService
  include JsonLdHelper

  def call(uri, prefetched_json = nil)
    @json = body_to_json(prefetched_json) || fetch_resource(uri)

    return unless supported_context?(@json) && expected_type?

    icon = CustomEmojiIcon.new(uri: @json['id'])
    icon.image_remote_url = @json['url']
    icon.save ? icon : nil
  rescue Addressable::InvalidURIError => e
    Rails.logger.debug e
    nil
  end

  private

  def expected_type?
    @json['type'] == 'Image'
  end
end

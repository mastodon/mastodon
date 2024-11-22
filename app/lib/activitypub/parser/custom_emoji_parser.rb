# frozen_string_literal: true

class ActivityPub::Parser::CustomEmojiParser
  include JsonLdHelper

  def initialize(json)
    @json = json
  end

  def uri
    @json['id']
  end

  def shortcode
    @json['name']&.delete(':')
  end

  def image_remote_url
    @json.dig('icon', 'url')
  end

  def updated_at
    @json['updated']&.to_datetime
  rescue ArgumentError
    nil
  end
end

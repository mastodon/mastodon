# frozen_string_literal: true

class ActivityPub::Parser::MediaAttachmentParser
  include JsonLdHelper

  def initialize(json)
    @json = json
  end

  # @param [MediaAttachment] previous_record
  def significantly_changes?(previous_record)
    remote_url != previous_record.remote_url ||
      thumbnail_remote_url != previous_record.thumbnail_remote_url ||
      description != previous_record.description
  end

  def remote_url
    url = Addressable::URI.parse(url_to_href(@json['url']))&.normalize&.to_s
    url unless unsupported_uri_scheme?(url)
  rescue Addressable::URI::InvalidURIError
    nil
  end

  def thumbnail_remote_url
    url = Addressable::URI.parse(@json['icon'].is_a?(Hash) ? @json['icon']['url'] : @json['icon'])&.normalize&.to_s
    url unless unsupported_uri_scheme?(url)
  rescue Addressable::URI::InvalidURIError
    nil
  end

  def description
    str = @json['summary'].presence || @json['name'].presence
    str = str.strip[0...MediaAttachment::MAX_DESCRIPTION_LENGTH] if str.present?
    str
  end

  def focus
    @json['focalPoint']
  end

  def blurhash
    supported_blurhash? ? @json['blurhash'] : nil
  end

  def file_content_type
    @json['mediaType'] || url_to_media_type(@json['url'])
  end

  private

  def supported_blurhash?
    components = begin
      blurhash = @json['blurhash']

      Blurhash.components(blurhash) if blurhash.present? && /^[\w#$%*+,-.:;=?@\[\]^{|}~]+$/.match?(blurhash)
    end

    components.present? && components.none? { |comp| comp > 5 }
  end
end

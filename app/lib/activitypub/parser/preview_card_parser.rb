# frozen_string_literal: true

class ActivityPub::Parser::PreviewCardParser
  include JsonLdHelper

  def initialize(json)
    @json = json
  end

  # @param [PreviewCard] previous_record
  def significantly_changes?(previous_record)
    url != previous_record.url
  end

  def url
    url = Addressable::URI.parse(@json['href'])&.normalize&.to_s
    url unless unsupported_uri_scheme?(url)
  rescue Addressable::URI::InvalidURIError
    nil
  end
end

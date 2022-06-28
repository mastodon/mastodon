# frozen_string_literal: true

module Webpacker::ManifestExtensions
  def lookup(name, pack_type = {})
    asset = super

    # rubocop:disable Style/SingleArgumentDig
    if pack_type[:with_integrity] && asset.respond_to?(:dig)
      [asset.dig('src'), asset.dig('integrity')]
    elsif asset.respond_to?(:dig)
      asset.dig('src')
    else
      asset
    end
    # rubocop:enable Style/SingleArgumentDig
  end
end

Webpacker::Manifest.prepend(Webpacker::ManifestExtensions)

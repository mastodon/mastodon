# frozen_string_literal: true

module Paperclip
  module UrlGeneratorExtensions
    # Monkey-patch Paperclip to use Addressable::URI's normalization instead
    # of the long-deprecated URI.esacpe
    def escape_url(url)
      if url.respond_to?(:escape)
        url.escape
      else
        Addressable::URI.parse(url).normalize.to_str.gsub(escape_regex) { |m| "%#{m.ord.to_s(16).upcase}" }
      end
    end
  end
end

Paperclip::UrlGenerator.prepend(Paperclip::UrlGeneratorExtensions)

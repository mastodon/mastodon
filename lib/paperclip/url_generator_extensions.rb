# frozen_string_literal: true

module Paperclip
  module UrlGeneratorExtensions
    def for_as_default(style_name)
      attachment_options[:interpolator].interpolate(default_url, @attachment, style_name)
    end
  end
end

Paperclip::UrlGenerator.prepend(Paperclip::UrlGeneratorExtensions)

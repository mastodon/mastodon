# frozen_string_literal: true

module Paperclip
  module MediaTypeSpoofDetectorExtensions
    MARCEL_MIME_TYPES = %w(audio/mpeg image/avif).freeze

    def calculated_content_type
      return @calculated_content_type if defined?(@calculated_content_type)

      detector = Paperclip::ContentTypeDetector.new(@file.path)

      @calculated_content_type = detector.detect
    end
  end
end

Paperclip::MediaTypeSpoofDetector.prepend(Paperclip::MediaTypeSpoofDetectorExtensions)

# frozen_string_literal: true

module Paperclip
  module MediaTypeSpoofDetectorExtensions
    def calculated_content_type
      @calculated_content_type ||= type_from_mime_magic || type_from_file_command
    end

    def type_from_mime_magic
      @type_from_mime_magic ||= begin
        begin
          File.open(@file.path) do |file|
            MimeMagic.by_magic(file)&.type
          end
        rescue Errno::ENOENT
          ''
        end
      end
    end

    def type_from_file_command
      @type_from_file_command ||= FileCommandContentTypeDetector.new(@file.path).detect
    end
  end
end

Paperclip::MediaTypeSpoofDetector.prepend(Paperclip::MediaTypeSpoofDetectorExtensions)

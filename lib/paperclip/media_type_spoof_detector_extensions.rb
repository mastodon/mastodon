# frozen_string_literal: true

module Paperclip
  module MediaTypeSpoofDetectorExtensions
    def mapping_override_mismatch?
      !Array(mapped_content_type).include?(calculated_content_type) && !Array(mapped_content_type).include?(type_from_mime_magic)
    end

    def calculated_media_type_from_mime_magic
      @calculated_media_type_from_mime_magic ||= type_from_mime_magic.split('/').first
    end

    def calculated_type_mismatch?
      !media_types_from_name.include?(calculated_media_type) && !media_types_from_name.include?(calculated_media_type_from_mime_magic)
    end

    def type_from_mime_magic
      @type_from_mime_magic ||= begin
        begin
          File.open(@file.path) do |file|
            MimeMagic.by_magic(file)&.type || ''
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

# frozen_string_literal: true

module Paperclip
  module AttachmentExtensions
    # We overwrite this method to support delayed processing in
    # Sidekiq. Since we process the original file to reduce disk
    # usage, and we still want to generate thumbnails straight
    # away, it's the only style we need to exclude
    def process_style?(style_name, style_args)
      if style_name == :original && instance.respond_to?(:delay_processing_for_attachment?) && instance.delay_processing_for_attachment?(name)
        false
      else
        style_args.empty? || style_args.include?(style_name)
      end
    end

    def storage_schema_version
      instance_read(:storage_schema_version) || 0
    end

    def assign_attributes
      super
      instance_write(:storage_schema_version, 1)
    end

    def variant?(other_filename)
      return true  if original_filename == other_filename
      return false if original_filename.nil?

      formats = styles.values.map(&:format).compact

      return false if formats.empty?

      other_extension = File.extname(other_filename)

      formats.include?(other_extension.delete('.')) && File.basename(other_filename, other_extension) == File.basename(original_filename, File.extname(original_filename))
    end
  end
end

Paperclip::Attachment.prepend(Paperclip::AttachmentExtensions)

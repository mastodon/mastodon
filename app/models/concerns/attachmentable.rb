# frozen_string_literal: true

require 'mime/types'

module Attachmentable
  extend ActiveSupport::Concern

  MAX_MATRIX_LIMIT = 16_777_216 # 4096x4096px or approx. 16MB

  included do
    before_post_process :set_file_extensions
    before_post_process :check_image_dimensions
  end

  private

  def set_file_extensions
    self.class.attachment_definitions.each_key do |attachment_name|
      attachment = send(attachment_name)

      next if attachment.blank?

      attachment.instance_write :file_name, [Paperclip::Interpolations.basename(attachment, :original), appropriate_extension(attachment)].delete_if(&:blank?).join('.')
    end
  end

  def check_image_dimensions
    self.class.attachment_definitions.each_key do |attachment_name|
      attachment = send(attachment_name)

      next if attachment.blank? || !/image.*/.match?(attachment.content_type) || attachment.queued_for_write[:original].blank?

      width, height = FastImage.size(attachment.queued_for_write[:original].path)

      raise Mastodon::DimensionsValidationError, "#{width}x#{height} images are not supported" if width.present? && height.present? && (width * height >= MAX_MATRIX_LIMIT)
    end
  end

  def appropriate_extension(attachment)
    mime_type = MIME::Types[attachment.content_type]

    extensions_for_mime_type = mime_type.empty? ? [] : mime_type.first.extensions
    original_extension       = Paperclip::Interpolations.extension(attachment, :original)
    proper_extension         = extensions_for_mime_type.first.to_s
    extension                = extensions_for_mime_type.include?(original_extension) ? original_extension : proper_extension
    extension                = 'jpeg' if extension == 'jpe'

    extension
  end
end

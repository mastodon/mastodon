# frozen_string_literal: true

module Attachmentable
  extend ActiveSupport::Concern

  included do
    before_post_process :set_file_extensions
  end

  private

  def set_file_extensions
    self.class.attachment_definitions.each_key do |attachment_name|
      attachment = send(attachment_name)
      next if attachment.blank?
      extension = Paperclip::Interpolations.content_type_extension(attachment, :original)
      basename  = Paperclip::Interpolations.basename(attachment, :original)
      attachment.instance_write :file_name, [basename, extension].delete_if(&:blank?).join('.')
    end
  end
end

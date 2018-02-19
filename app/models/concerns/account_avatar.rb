# frozen_string_literal: true

module AccountAvatar
  extend ActiveSupport::Concern

  IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif'].freeze

  class_methods do
    def avatar_styles(file)
      styles   = {}
      geometry = Paperclip::Geometry.from_file(file)

      styles[:original] = '120x120#' if geometry.width != geometry.height || geometry.width > 120 || geometry.height > 120
      styles[:static]   = { format: 'png', convert_options: '-coalesce' } if file.content_type == 'image/gif'

      styles
    rescue Paperclip::Errors::NotIdentifiedByImageMagickError
      {}
    end

    private :avatar_styles
  end

  included do
    # Avatar upload
    has_attached_file :avatar, styles: ->(f) { avatar_styles(f) }, convert_options: { all: '-strip' }
    validates_attachment_content_type :avatar, content_type: IMAGE_MIME_TYPES
    validates_attachment_size :avatar, less_than: 2.megabytes
  end

  def avatar_original_url
    avatar.url(:original)
  end

  def avatar_static_url
    avatar_content_type == 'image/gif' ? avatar.url(:static) : avatar_original_url
  end
end

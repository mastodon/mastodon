# frozen_string_literal: true

module Account::Avatar
  extend ActiveSupport::Concern

  AVATAR_IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'].freeze
  AVATAR_LIMIT = 8.megabytes
  AVATAR_DIMENSIONS = [400, 400].freeze
  AVATAR_GEOMETRY = [AVATAR_DIMENSIONS.first, AVATAR_DIMENSIONS.last].join('x')

  class_methods do
    def avatar_styles(file)
      styles = { original: { geometry: "#{AVATAR_GEOMETRY}#", file_geometry_parser: FastGeometryParser } }
      styles[:static] = { geometry: "#{AVATAR_GEOMETRY}#", format: 'png', convert_options: '-coalesce', file_geometry_parser: FastGeometryParser } if file.content_type == 'image/gif'
      styles
    end

    private :avatar_styles
  end

  included do
    # Avatar upload
    has_attached_file :avatar, styles: ->(f) { avatar_styles(f) }, convert_options: { all: '+profile "!icc,*" +set date:modify +set date:create +set date:timestamp' }, processors: [:lazy_thumbnail]
    validates_attachment_content_type :avatar, content_type: AVATAR_IMAGE_MIME_TYPES
    validates_attachment_size :avatar, less_than: AVATAR_LIMIT
    remotable_attachment :avatar, AVATAR_LIMIT, suppress_errors: false

    validates :avatar_description, length: { maximum: MediaAttachment::MAX_DESCRIPTION_LENGTH }
  end

  def avatar_original_url
    avatar.url(:original)
  end

  def avatar_static_url
    avatar_content_type == 'image/gif' ? avatar.url(:static) : avatar_original_url
  end
end

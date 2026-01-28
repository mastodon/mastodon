# frozen_string_literal: true

module Account::Header
  extend ActiveSupport::Concern

  HEADER_IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'].freeze
  HEADER_LIMIT = 8.megabytes
  HEADER_DIMENSIONS = [1500, 500].freeze
  HEADER_GEOMETRY = [HEADER_DIMENSIONS.first, HEADER_DIMENSIONS.last].join('x')
  HEADER_MAX_PIXELS = HEADER_DIMENSIONS.first * HEADER_DIMENSIONS.last

  class_methods do
    def header_styles(file)
      styles = { original: { pixels: HEADER_MAX_PIXELS, file_geometry_parser: FastGeometryParser } }
      styles[:static] = { format: 'png', convert_options: '-coalesce', file_geometry_parser: FastGeometryParser } if file.content_type == 'image/gif'
      styles
    end

    private :header_styles
  end

  included do
    # Header upload
    has_attached_file :header, styles: ->(f) { header_styles(f) }, convert_options: { all: '+profile "!icc,*" +set date:modify +set date:create +set date:timestamp' }, processors: [:lazy_thumbnail]
    validates_attachment_content_type :header, content_type: HEADER_IMAGE_MIME_TYPES
    validates_attachment_size :header, less_than: HEADER_LIMIT
    remotable_attachment :header, HEADER_LIMIT, suppress_errors: false

    validates :header_description, length: { maximum: MediaAttachment::MAX_DESCRIPTION_LENGTH }
  end

  def header_original_url
    header.url(:original)
  end

  def header_static_url
    header_content_type == 'image/gif' ? header.url(:static) : header_original_url
  end
end

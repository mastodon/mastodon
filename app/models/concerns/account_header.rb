# frozen_string_literal: true

module AccountHeader
  extend ActiveSupport::Concern

  IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif'].freeze
  LIMIT = ((ENV['HEADER_LIMIT'] || 2).to_i).megabytes
  MAX_PIXELS = 750_000 # 1500x500px

  class_methods do
    def header_styles(file)
      styles = { original: { pixels: MAX_PIXELS, file_geometry_parser: FastGeometryParser } }
      styles[:static] = { format: 'png', convert_options: '-coalesce', file_geometry_parser: FastGeometryParser } if file.content_type == 'image/gif'
      styles
    end

    private :header_styles
  end

  included do
    # Header upload
    has_attached_file :header, styles: ->(f) { header_styles(f) }, convert_options: { all: '-strip' }, processors: [:lazy_thumbnail]
    validates_attachment_content_type :header, content_type: IMAGE_MIME_TYPES
    validates_attachment_size :header, less_than: LIMIT
    remotable_attachment :header, LIMIT, suppress_errors: false
  end

  def header_original_url
    header.url(:original)
  end

  def header_static_url
    header_content_type == 'image/gif' ? header.url(:static) : header_original_url
  end
end

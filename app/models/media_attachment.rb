# frozen_string_literal: true

class MediaAttachment < ApplicationRecord
  IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif'].freeze
  VIDEO_MIME_TYPES = ['video/webm', 'video/mp4'].freeze

  belongs_to :account, inverse_of: :media_attachments
  belongs_to :status,  inverse_of: :media_attachments

  has_attached_file :file,
                    styles: -> (f) { file_styles f },
                    processors: -> (f) { f.video? ? [:transcoder] : [:thumbnail] },
                    convert_options: { all: '-strip' }
  validates_attachment_content_type :file, content_type: IMAGE_MIME_TYPES + VIDEO_MIME_TYPES
  validates_attachment_size :file, less_than: 4.megabytes

  validates :account, presence: true

  def local?
    remote_url.blank?
  end

  def file_remote_url=(url)
    self.file = URI.parse(url)
  rescue OpenURI::HTTPError => e
    Rails.logger.debug "Error fetching remote attachment: #{e}"
  end

  def image?
    IMAGE_MIME_TYPES.include? file_content_type
  end

  def video?
    VIDEO_MIME_TYPES.include? file_content_type
  end

  def type
    image? ? 'image' : 'video'
  end

  class << self
    private

    def file_styles(f)
      if f.instance.image?
        {
          original: '100%',
          small: '510x680>',
        }
      else
        {
          small: {
            convert_options: {
              output: {
                vf: 'scale=\'min(510\, iw):min(680\, ih)\':force_original_aspect_ratio=decrease',
              },
            },
            format: 'png',
            time: 1,
          },
        }
      end
    end
  end
end

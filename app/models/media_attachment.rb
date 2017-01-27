# frozen_string_literal: true

class MediaAttachment < ApplicationRecord
  IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif'].freeze
  VIDEO_MIME_TYPES = ['video/webm', 'video/mp4'].freeze

  belongs_to :account, inverse_of: :media_attachments
  belongs_to :status,  inverse_of: :media_attachments

  has_attached_file :file,
                    styles: -> (f) { file_styles f },
                    processors: -> (f) { f.video? ? [:transcoder] : [:thumbnail] },
                    convert_options: { all: '-quality 90 -strip' }
  validates_attachment_content_type :file, content_type: IMAGE_MIME_TYPES + VIDEO_MIME_TYPES
  validates_attachment_size :file, less_than: 8.megabytes

  validates :account, presence: true

  scope :local, -> { where(remote_url: '') }
  default_scope { order('id asc') }

  def local?
    remote_url.blank?
  end

  def file_remote_url=(url)
    self.file = URI.parse(url)
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

  def to_param
    shortcode
  end

  before_create :set_shortcode

  class << self
    private

    def file_styles(f)
      if f.instance.image?
        {
          original: '1280x1280>',
          small: '400x400>',
        }
      else
        {
          small: {
            convert_options: {
              output: {
                vf: 'scale=\'min(400\, iw):min(400\, ih)\':force_original_aspect_ratio=decrease',
              },
            },
            format: 'png',
            time: 1,
          },
        }
      end
    end
  end

  private

  def set_shortcode
    return unless local?

    loop do
      self.shortcode = SecureRandom.urlsafe_base64(14)
      break if MediaAttachment.find_by(shortcode: shortcode).nil?
    end
  end
end

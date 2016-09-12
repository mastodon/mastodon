class MediaAttachment < ApplicationRecord
  IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif']
  VIDEO_MIME_TYPES = ['video/webm']

  belongs_to :account, inverse_of: :media_attachments
  belongs_to :status,  inverse_of: :media_attachments

  has_attached_file :file, styles: lambda { |f| f.instance.image? ? { small: '510x680>' } : { small: { format: 'webm' } } }, processors: lambda { |f| f.video? ? [:transcoder] : [:thumbnail] }
  validates_attachment_content_type :file, content_type: IMAGE_MIME_TYPES + VIDEO_MIME_TYPES
  validates_attachment_size :file, less_than: 4.megabytes

  validates :account, presence: true

  def local?
    self.remote_url.blank?
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
end

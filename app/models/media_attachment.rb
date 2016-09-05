class MediaAttachment < ApplicationRecord
  belongs_to :account, inverse_of: :media_attachments
  belongs_to :status,  inverse_of: :media_attachments

  has_attached_file :file, styles: { small: '510x680>' }
  validates_attachment_content_type :file, content_type: /\Aimage\/.*\z/

  validates :account, presence: true

  def local?
    self.remote_url.blank?
  end

  def file_remote_url=(url)
    self.file = URI.parse(url)
  end
end

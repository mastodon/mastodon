# frozen_string_literal: true

class PreviewCard < ApplicationRecord
  IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif'].freeze

  self.inheritance_column = false

  enum type: [:link, :photo, :video, :rich]

  belongs_to :status

  has_attached_file :image, styles: { original: '120x120#' }, convert_options: { all: '-quality 80 -strip' }

  validates :url, presence: true
  validates_attachment_content_type :image, content_type: IMAGE_MIME_TYPES
  validates_attachment_size :image, less_than: 1.megabytes

  def save_with_optional_image!
    save!
  rescue ActiveRecord::RecordInvalid
    self.image = nil
    save!
  end
end

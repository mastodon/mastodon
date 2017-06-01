# frozen_string_literal: true
# == Schema Information
#
# Table name: preview_cards
#
#  id                 :integer          not null, primary key
#  status_id          :integer
#  url                :string           default(""), not null
#  title              :string
#  description        :string
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  type               :integer          default("link"), not null
#  html               :text             default(""), not null
#  author_name        :string           default(""), not null
#  author_url         :string           default(""), not null
#  provider_name      :string           default(""), not null
#  provider_url       :string           default(""), not null
#  width              :integer          default(0), not null
#  height             :integer          default(0), not null
#

class PreviewCard < ApplicationRecord
  IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif'].freeze

  self.inheritance_column = false

  enum type: [:link, :photo, :video, :rich]

  belongs_to :status

  has_attached_file :image, styles: { original: '120x120#' }, convert_options: { all: '-quality 80 -strip' }

  include Attachmentable
  include Remotable

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

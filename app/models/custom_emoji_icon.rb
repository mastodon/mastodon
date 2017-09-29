# frozen_string_literal: true
# == Schema Information
#
# Table name: custom_emoji_icons
#
#  id                 :integer          not null, primary key
#  uri                :string
#  image_remote_url   :string
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#

class CustomEmojiIcon < ApplicationRecord
  has_many :custom_emojis, inverse_of: :custom_emoji_icon

  has_attached_file :image
  validates_attachment :image, content_type: { content_type: 'image/png' }, presence: true, size: { in: 0..50.kilobytes }

  scope :local, -> { where(uri: nil) }

  include Remotable

  def self.find_local(id)
    local.find(id)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def local?
    uri.nil?
  end

  def object_type
    :emoji
  end
end

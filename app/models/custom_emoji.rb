# frozen_string_literal: true
# == Schema Information
#
# Table name: custom_emojis
#
#  id                 :integer          not null, primary key
#  shortcode          :string           default(""), not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  account_id         :integer          not null
#  href               :string
#  uri                :string
#

class CustomEmoji < ApplicationRecord
  SHORTCODE_RE_FRAGMENT = '[a-zA-Z0-9_]{2,}'

  SCAN_RE = /(?<=[^[:alnum:]:]|\n|^)
    :(#{SHORTCODE_RE_FRAGMENT}):
    (?=[^[:alnum:]:]|$)/x

  belongs_to :account, required: true

  has_attached_file :image
  has_many :favourites, class_name: :emoji_favourite, inverse_of: :custom_emoji, dependent: :destroy

  validates_attachment :image, content_type: { content_type: 'image/png' }, presence: true, size: { in: 0..50.kilobytes }

  include Remotable

  def object_type
    :emoji
  end
end

# frozen_string_literal: true
# == Schema Information
#
# Table name: custom_emojis
#
#  id                 :bigint(8)        not null, primary key
#  shortcode          :string           default(""), not null
#  domain             :string
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  disabled           :boolean          default(FALSE), not null
#  uri                :string
#  image_remote_url   :string
#  visible_in_picker  :boolean          default(TRUE), not null
#

class CustomEmoji < ApplicationRecord
  LIMIT = 50.kilobytes

  SHORTCODE_RE_FRAGMENT = '[a-zA-Z0-9_]{2,}'

  STATIC_EMOJI_STYLE = {
    format: 'png',
    source_file_options: '-channel rgba -background "rgba(0,0,0,0)"',
    convert_options: '-coalesce -strip',
    geometry: '200x200>',
  }.freeze

  SCAN_RE = /(?<=[^[:alnum:]:]|\n|^)
    :(#{SHORTCODE_RE_FRAGMENT}):
    (?=[^[:alnum:]:]|$)/x

  has_one :local_counterpart, -> { where(domain: nil) }, class_name: 'CustomEmoji', primary_key: :shortcode, foreign_key: :shortcode

  has_attached_file :image, styles: ->(f) { emoji_styles f }

  before_validation :downcase_domain

  validates_attachment :image, content_type: { content_type: ['image/png', 'image/svg+xml', 'image/svg'] }, presence: true, size: { less_than: LIMIT }
  validates :shortcode, uniqueness: { scope: :domain }, format: { with: /\A#{SHORTCODE_RE_FRAGMENT}\z/ }, length: { minimum: 2 }

  scope :local,      -> { where(domain: nil) }
  scope :remote,     -> { where.not(domain: nil) }
  scope :alphabetic, -> { order(domain: :asc, shortcode: :asc) }

  remotable_attachment :image, LIMIT

  include Attachmentable

  after_commit :remove_entity_cache
  before_create :set_extension

  def local?
    domain.nil?
  end

  def object_type
    :emoji
  end

  class << self
    def from_text(text, domain)
      return [] if text.blank?

      shortcodes = text.scan(SCAN_RE).map(&:first).uniq

      return [] if shortcodes.empty?

      EntityCache.instance.emoji(shortcodes, domain)
    end

    def search(shortcode)
      where('"custom_emojis"."shortcode" ILIKE ?', "%#{shortcode}%")
    end

    private

    def emoji_styles(attachment)
      if ['image/svg', 'image/svg+xml'].include?(attachment.instance.image_content_type) && ENV['ALLOW_UNSAFE_UPLOADS'] != 'true'
        {
          static: STATIC_EMOJI_STYLE,
          original: STATIC_EMOJI_STYLE,
        }
      else
        {
          static: STATIC_EMOJI_STYLE,
        }
      end
    end
  end

  private

  def remove_entity_cache
    Rails.cache.delete(EntityCache.instance.to_key(:emoji, shortcode, domain))
  end

  def downcase_domain
    self.domain = domain.downcase unless domain.nil?
  end

  def set_extension
    return if image_file_name.nil?
    basename = File.basename(image_file_name, '.*')
    if ['image/svg', 'image/svg+xml'].include?(image_content_type) && ENV['ALLOW_UNSAFE_UPLOADS'] != 'true'
      image.instance_write(:file_name, basename + '.png')
    end
  end
end

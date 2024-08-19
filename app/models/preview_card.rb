# frozen_string_literal: true

# == Schema Information
#
# Table name: preview_cards
#
#  id                           :bigint(8)        not null, primary key
#  url                          :string           default(""), not null
#  title                        :string           default(""), not null
#  description                  :string           default(""), not null
#  image_file_name              :string
#  image_content_type           :string
#  image_file_size              :integer
#  image_updated_at             :datetime
#  type                         :integer          default("link"), not null
#  html                         :text             default(""), not null
#  author_name                  :string           default(""), not null
#  author_url                   :string           default(""), not null
#  provider_name                :string           default(""), not null
#  provider_url                 :string           default(""), not null
#  width                        :integer          default(0), not null
#  height                       :integer          default(0), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  embed_url                    :string           default(""), not null
#  image_storage_schema_version :integer
#  blurhash                     :string
#  language                     :string
#  max_score                    :float
#  max_score_at                 :datetime
#  trendable                    :boolean
#  link_type                    :integer
#  published_at                 :datetime
#  image_description            :string           default(""), not null
#  author_account_id            :bigint(8)
#

class PreviewCard < ApplicationRecord
  include Attachmentable

  IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'].freeze
  LIMIT = 2.megabytes

  BLURHASH_OPTIONS = {
    x_comp: 4,
    y_comp: 4,
  }.freeze

  # URL size limit to safely store in PosgreSQL's unique indexes
  # Technically this is a byte-size limit but we use it as a
  # character limit to work with length validation
  URL_CHARACTER_LIMIT = 2692

  self.inheritance_column = false

  enum :type, { link: 0, photo: 1, video: 2, rich: 3 }
  enum :link_type, { unknown: 0, article: 1 }

  has_many :preview_cards_statuses, dependent: :delete_all, inverse_of: :preview_card
  has_many :statuses, through: :preview_cards_statuses

  has_one :trend, class_name: 'PreviewCardTrend', inverse_of: :preview_card, dependent: :destroy
  belongs_to :author_account, class_name: 'Account', optional: true

  has_attached_file :image,
                    processors: [Rails.configuration.x.use_vips ? :lazy_thumbnail : :thumbnail, :blurhash_transcoder],
                    styles: ->(f) { image_styles(f) },
                    convert_options: { all: '-quality 90 +profile "!icc,*" +set date:modify +set date:create +set date:timestamp' },
                    validate_media_type: false

  validates :url, presence: true, uniqueness: true, url: true, length: { maximum: URL_CHARACTER_LIMIT }
  validates_attachment_content_type :image, content_type: IMAGE_MIME_TYPES
  validates_attachment_size :image, less_than: LIMIT
  remotable_attachment :image, LIMIT

  scope :cached, -> { where.not(image_file_name: [nil, '']) }

  before_save :extract_dimensions, if: :link?

  # This can be set by the status when retrieving the preview card using the join model
  attr_accessor :original_url

  def appropriate_for_trends?
    link? && article? && title.present? && description.present? && image.present? && provider_name.present?
  end

  def domain
    @domain ||= Addressable::URI.parse(url).normalized_host
  end

  def provider
    @provider ||= PreviewCardProvider.matching_domain(domain)
  end

  def trendable?
    if attributes['trendable'].nil?
      provider&.trendable?
    else
      attributes['trendable']
    end
  end

  def requires_review?
    attributes['trendable'].nil? && (provider.nil? || provider.requires_review?)
  end

  def requires_review_notification?
    attributes['trendable'].nil? && (provider.nil? || provider.requires_review_notification?)
  end

  def decaying?
    max_score_at && max_score_at >= Trends.links.options[:max_score_cooldown].ago && max_score_at < 1.day.ago
  end

  attr_writer :provider

  def local?
    false
  end

  def missing_image?
    width.present? && height.present? && image_file_name.blank?
  end

  def save_with_optional_image!
    save!
  rescue ActiveRecord::RecordInvalid
    self.image = nil
    save!
  end

  def history
    @history ||= Trends::History.new('links', id)
  end

  def authors
    @authors ||= [PreviewCard::Author.new(self)]
  end

  class Author < ActiveModelSerializers::Model
    attributes :name, :url, :account

    def initialize(preview_card)
      super(
        name: preview_card.author_name,
        url: preview_card.author_url,
        account: preview_card.author_account,
      )
    end
  end

  class << self
    private

    def image_styles(file)
      styles = {
        original: {
          pixels: 230_400, # 640x360px
          file_geometry_parser: FastGeometryParser,
          convert_options: '-coalesce',
          blurhash: BLURHASH_OPTIONS,
        },
      }

      styles[:original][:format] = 'jpg' if file.instance.image_content_type == 'image/gif'
      styles
    end
  end

  private

  def extract_dimensions
    file = image.queued_for_write[:original]

    return if file.nil?

    width, height = FastImage.size(file.path)

    return nil if width.nil?

    self.width  = width
    self.height = height
  end
end

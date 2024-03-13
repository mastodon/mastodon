# frozen_string_literal: true

# == Schema Information
#
# Table name: preview_card_providers
#
#  id                  :bigint(8)        not null, primary key
#  domain              :string           default(""), not null
#  icon_file_name      :string
#  icon_content_type   :string
#  icon_file_size      :bigint(8)
#  icon_updated_at     :datetime
#  trendable           :boolean
#  reviewed_at         :datetime
#  requested_review_at :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class PreviewCardProvider < ApplicationRecord
  include Paginable
  include DomainNormalizable
  include Attachmentable

  ICON_MIME_TYPES = %w(image/x-icon image/vnd.microsoft.icon image/png).freeze
  LIMIT = 1.megabyte

  validates :domain, presence: true, uniqueness: true, domain: true

  has_attached_file :icon, styles: { static: { format: 'png', convert_options: '-coalesce +profile "!icc,*" +set date:modify +set date:create +set date:timestamp' } }, validate_media_type: false
  validates_attachment :icon, content_type: { content_type: ICON_MIME_TYPES }, size: { less_than: LIMIT }
  remotable_attachment :icon, LIMIT

  scope :trendable, -> { where(trendable: true) }
  scope :not_trendable, -> { where(trendable: false) }
  scope :reviewed, -> { where.not(reviewed_at: nil) }
  scope :pending_review, -> { where(reviewed_at: nil) }

  def requires_review?
    reviewed_at.nil?
  end

  def reviewed?
    reviewed_at.present?
  end

  def requested_review?
    requested_review_at.present?
  end

  def requires_review_notification?
    requires_review? && !requested_review?
  end

  def self.matching_domain(domain)
    segments = domain.split('.')
    where(domain: segments.map.with_index { |_, i| segments[i..].join('.') }).by_domain_length.first
  end
end

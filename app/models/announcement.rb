# frozen_string_literal: true

# == Schema Information
#
# Table name: announcements
#
#  id                   :bigint(8)        not null, primary key
#  all_day              :boolean          default(FALSE), not null
#  ends_at              :datetime
#  notification_sent_at :datetime
#  published            :boolean          default(FALSE), not null
#  published_at         :datetime
#  scheduled_at         :datetime
#  starts_at            :datetime
#  status_ids           :bigint(8)        is an Array
#  text                 :text             default(""), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Announcement < ApplicationRecord
  include Reactions

  scope :unpublished, -> { where(published: false) }
  scope :published, -> { where(published: true) }
  scope :chronological, -> { order(coalesced_chronology_timestamps.asc) }
  scope :reverse_chronological, -> { order(coalesced_chronology_timestamps.desc) }

  has_many :announcement_mutes, dependent: :destroy

  validates :text, presence: true
  validates :starts_at, presence: true, if: :ends_at?
  validates :ends_at, presence: true, if: :starts_at?

  before_validation :set_published, on: :create

  class << self
    def coalesced_chronology_timestamps
      Arel.sql(
        <<~SQL.squish
          COALESCE(announcements.starts_at, announcements.scheduled_at, announcements.published_at, announcements.created_at)
        SQL
      )
    end
  end

  def to_log_human_identifier
    text
  end

  def publish!
    update!(published: true, published_at: Time.now.utc, scheduled_at: nil)
  end

  def unpublish!
    update!(published: false, scheduled_at: nil)
  end

  def notification_sent?
    notification_sent_at.present?
  end

  def mentions
    @mentions ||= Account.from_text(text)
  end

  def statuses
    @statuses ||= begin
      if status_ids.nil?
        []
      else
        Status.with_includes.distributable_visibility.where(id: status_ids)
      end
    end
  end

  def tags
    @tags ||= Tag.find_or_create_by_names(Extractor.extract_hashtags(text))
  end

  def emojis
    @emojis ||= CustomEmoji.from_text(text)
  end

  def scope_for_notification
    User.confirmed.joins(:account).merge(Account.without_suspended)
  end

  private

  def set_published
    return unless scheduled_at.blank? || scheduled_at.past?

    self.published = true
    self.published_at = Time.now.utc
  end
end

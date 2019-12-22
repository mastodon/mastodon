# frozen_string_literal: true

class Announcement < ApplicationRecord
  after_commit :queue_publish, on: :create

  scope :unpublished, -> { where(published: false) }
  scope :published, -> { where(published: true) }
  scope :without_muted, ->(account) { joins("LEFT OUTER JOIN announcement_mutes ON announcement_mutes.announcement_id = announcements.id AND announcement_mutes.account_id = #{account.id}").where('announcement_mutes.id IS NULL') }

  has_many :announcement_mutes, dependent: :destroy

  before_validation :set_starts_at, on: :create
  before_validation :set_ends_at, on: :create

  def mentions
    @mentions ||= Account.from_text(text)
  end

  def tags
    @tags ||= Tag.find_or_create_by_names(Extractor.extract_hashtags(text))
  end

  def emojis
    @emojis ||= CustomEmoji.from_text(text)
  end

  private

  def set_starts_at
    self.starts_at = starts_at.change(hour: 0, min: 0, sec: 0) if all_day? && starts_at.present?
  end

  def set_ends_at
    self.ends_at = ends_at.change(hour: 23, min: 59, sec: 59) if all_day? && ends_at.present?
  end

  def queue_publish
    PublishScheduledAnnouncementWorker.perform_async(id) if scheduled_at.blank?
  end
end

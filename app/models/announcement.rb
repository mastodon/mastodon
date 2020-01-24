# frozen_string_literal: true

# == Schema Information
#
# Table name: announcements
#
#  id           :bigint(8)        not null, primary key
#  text         :text             default(""), not null
#  published    :boolean          default(FALSE), not null
#  all_day      :boolean          default(FALSE), not null
#  scheduled_at :datetime
#  starts_at    :datetime
#  ends_at      :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Announcement < ApplicationRecord
  after_commit :queue_publish, on: :create

  scope :unpublished, -> { where(published: false) }
  scope :published, -> { where(published: true) }
  scope :without_muted, ->(account) { joins("LEFT OUTER JOIN announcement_mutes ON announcement_mutes.announcement_id = announcements.id AND announcement_mutes.account_id = #{account.id}").where('announcement_mutes.id IS NULL') }
  scope :chronological, -> { order(Arel.sql('COALESCE(announcements.starts_at, announcements.scheduled_at, announcements.created_at) ASC')) }

  has_many :announcement_mutes, dependent: :destroy
  has_many :announcement_reactions, dependent: :destroy

  validates :text, presence: true
  validates :starts_at, presence: true, if: -> { ends_at.present? }
  validates :ends_at, presence: true, if: -> { starts_at.present? }

  before_validation :set_all_day
  before_validation :set_starts_at, on: :create
  before_validation :set_ends_at, on: :create

  def time_range?
    starts_at.present? && ends_at.present?
  end

  def mentions
    @mentions ||= Account.from_text(text)
  end

  def tags
    @tags ||= Tag.find_or_create_by_names(Extractor.extract_hashtags(text))
  end

  def emojis
    @emojis ||= CustomEmoji.from_text(text)
  end

  def reactions(account = nil)
    records = begin
      scope = announcement_reactions.group(:announcement_id, :name, :custom_emoji_id).order(Arel.sql('MIN(created_at) ASC'))

      if account.nil?
        scope.select('name, custom_emoji_id, count(*) as count, false as me')
      else
        scope.select("name, custom_emoji_id, count(*) as count, exists(select 1 from announcement_reactions r where r.account_id = #{account.id} and r.announcement_id = announcement_reactions.announcement_id and r.name = announcement_reactions.name) as me")
      end
    end

    ActiveRecord::Associations::Preloader.new.preload(records, :custom_emoji)
    records
  end

  private

  def set_all_day
    self.all_day = false if starts_at.blank? || ends_at.blank?
  end

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

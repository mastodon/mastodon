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
#  published_at :datetime
#  status_ids   :bigint(8)        is an Array
#

class Announcement < ApplicationRecord
  scope :unpublished, -> { where(published: false) }
  scope :published, -> { where(published: true) }
  scope :without_muted, ->(account) { joins("LEFT OUTER JOIN announcement_mutes ON announcement_mutes.announcement_id = announcements.id AND announcement_mutes.account_id = #{account.id}").where(announcement_mutes: { id: nil }) }
  scope :chronological, -> { order(Arel.sql('COALESCE(announcements.starts_at, announcements.scheduled_at, announcements.published_at, announcements.created_at) ASC')) }
  scope :reverse_chronological, -> { order(Arel.sql('COALESCE(announcements.starts_at, announcements.scheduled_at, announcements.published_at, announcements.created_at) DESC')) }

  has_many :announcement_mutes, dependent: :destroy
  has_many :announcement_reactions, dependent: :destroy

  validates :text, presence: true
  validates :starts_at, presence: true, if: -> { ends_at.present? }
  validates :ends_at, presence: true, if: -> { starts_at.present? }

  before_validation :set_published, on: :create

  def to_log_human_identifier
    text
  end

  def publish!
    update!(published: true, published_at: Time.now.utc, scheduled_at: nil)
  end

  def unpublish!
    update!(published: false, scheduled_at: nil)
  end

  def time_range?
    starts_at.present? && ends_at.present?
  end

  def mentions
    @mentions ||= Account.from_text(text)
  end

  def statuses
    @statuses ||= if status_ids.nil?
                    []
                  else
                    Status.where(id: status_ids, visibility: %i(public unlisted))
                  end
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

  def set_published
    return unless scheduled_at.blank? || scheduled_at.past?

    self.published = true
    self.published_at = Time.now.utc
  end
end

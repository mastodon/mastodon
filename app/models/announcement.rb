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
  scope :chronological, -> { order(coalesced_chronology_timestamps.asc) }
  scope :reverse_chronological, -> { order(coalesced_chronology_timestamps.desc) }

  has_many :announcement_mutes, dependent: :destroy
  has_many :announcement_reactions, dependent: :destroy

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

  def mentions
    @mentions ||= Account.from_text(text)
  end

  def statuses
    @statuses ||= if status_ids.nil?
                    []
                  else
                    Status.where(id: status_ids, visibility: [:public, :unlisted])
                  end
  end

  def tags
    @tags ||= Tag.find_or_create_by_names(Extractor.extract_hashtags(text))
  end

  def emojis
    @emojis ||= CustomEmoji.from_text(text)
  end

  def reactions(account = nil)
    grouped_ordered_announcement_reactions.select(
      [:name, :custom_emoji_id, 'COUNT(*) as count'].tap do |values|
        values << value_for_reaction_me_column(account)
      end
    ).to_a.tap do |records|
      ActiveRecord::Associations::Preloader.new(records: records, associations: :custom_emoji).call
    end
  end

  private

  def grouped_ordered_announcement_reactions
    announcement_reactions
      .group(:announcement_id, :name, :custom_emoji_id)
      .order(
        Arel.sql('MIN(created_at)').asc
      )
  end

  def value_for_reaction_me_column(account)
    if account.nil?
      'FALSE AS me'
    else
      <<~SQL.squish
        EXISTS(
          SELECT 1
          FROM announcement_reactions inner_reactions
          WHERE inner_reactions.account_id = #{account.id}
            AND inner_reactions.announcement_id = announcement_reactions.announcement_id
            AND inner_reactions.name = announcement_reactions.name
        ) AS me
      SQL
    end
  end

  def set_published
    return unless scheduled_at.blank? || scheduled_at.past?

    self.published = true
    self.published_at = Time.now.utc
  end
end

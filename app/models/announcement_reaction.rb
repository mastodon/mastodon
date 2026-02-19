# frozen_string_literal: true

# == Schema Information
#
# Table name: announcement_reactions
#
#  id              :bigint(8)        not null, primary key
#  name            :string           default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :bigint(8)        not null
#  announcement_id :bigint(8)        not null
#  custom_emoji_id :bigint(8)
#

class AnnouncementReaction < ApplicationRecord
  before_validation :set_custom_emoji, if: :name?
  after_commit :queue_publish

  belongs_to :account
  belongs_to :announcement, inverse_of: :announcement_reactions
  belongs_to :custom_emoji, optional: true

  validates :name, presence: true
  validates_with ReactionValidator

  private

  def set_custom_emoji
    self.custom_emoji = CustomEmoji.local.enabled.find_by(shortcode: name)
  end

  def queue_publish
    PublishAnnouncementReactionWorker.perform_async(announcement_id, name) unless announcement.destroyed?
  end
end

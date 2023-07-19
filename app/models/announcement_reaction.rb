# frozen_string_literal: true

# == Schema Information
#
# Table name: announcement_reactions
#
#  id              :bigint(8)        not null, primary key
#  account_id      :bigint(8)
#  announcement_id :bigint(8)
#  name            :string           default(""), not null
#  custom_emoji_id :bigint(8)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class AnnouncementReaction < ApplicationRecord
  before_validation :set_custom_emoji
  after_commit :queue_publish

  belongs_to :account
  belongs_to :announcement, inverse_of: :announcement_reactions
  belongs_to :custom_emoji, optional: true

  validates :name, presence: true
  validates_with ReactionValidator

  private

  def set_custom_emoji
    self.custom_emoji = CustomEmoji.local.find_by(disabled: false, shortcode: name) if name.present?
  end

  def queue_publish
    PublishAnnouncementReactionWorker.perform_async(announcement_id, name) unless announcement.destroyed?
  end
end

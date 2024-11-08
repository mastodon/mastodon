# frozen_string_literal: true

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
    self.custom_emoji = CustomEmoji.local.enabled.find_by(shortcode: name) if name.present?
  end

  def queue_publish
    PublishAnnouncementReactionWorker.perform_async(announcement_id, name) unless announcement.destroyed?
  end
end

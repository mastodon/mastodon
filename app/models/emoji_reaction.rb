# frozen_string_literal: true

# == Schema Information
#
# Table name: emoji_reactions
#
#  id         :bigint(8)        not null, primary key
#  account_id :bigint(8)
#  status_id  :bigint(8)
#  name       :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EmojiReaction < ApplicationRecord
  belongs_to :account
  belongs_to :status, inverse_of: :reactions
  belongs_to :custom_emoji, optional: true

  validates :name, presence: true
  validates_with EmojiReactionValidator

  # For now, don't support custom emoji, but use the same validation code
  def custom_emoji_id
    nil
  end
end

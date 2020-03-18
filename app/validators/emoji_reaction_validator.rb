# frozen_string_literal: true

class EmojiReactionValidator < ActiveModel::Validator
  def validate(reaction)
    return if reaction.name.blank?

    reaction.errors.add(:name, I18n.t('reactions.errors.unrecognized_emoji')) if reaction.custom_emoji_id.blank? && !unicode_emoji?(reaction.name)
  end

  private

  def unicode_emoji?(name)
    ReactionValidator::SUPPORTED_EMOJIS.include?(name)
  end
end

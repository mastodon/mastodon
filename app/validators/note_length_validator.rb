# frozen_string_literal: true

require 'mastodon/character_counter'

class NoteLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :too_long, count: options[:maximum]) if too_long?(value)
  end

  private

  def too_long?(value)
    Mastodon::CharacterCounter.new.countable_note_text(value).each_grapheme_cluster.size > options[:maximum]
  end
end

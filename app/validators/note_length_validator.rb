# frozen_string_literal: true

require 'character_counter'

class NoteLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :too_long, count: options[:maximum]) if too_long?(value)
  end

  private

  def too_long?(value)
    @counter = CharacterCounter.new
    @counter.character_count(@counter.countable_text(value)) > options[:maximum]
  end
end

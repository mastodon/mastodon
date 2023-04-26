# frozen_string_literal: true

module AccountSearchable
  extend ActiveSupport::Concern

  def searchable_text
    PlainTextFormatter.new(note, local?).to_s if discoverable?
  end

  def searchable_properties
    [].tap do |properties|
      properties << 'bot' if bot?
      properties << 'verified' if fields.any?(&:verified?)
    end
  end
end

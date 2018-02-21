# frozen_string_literal: true
# == Schema Information
#
# Table name: text_blocks
#
#  id         :integer          not null, primary key
#  text       :string           not null
#  severity   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TextBlock < ApplicationRecord
  after_commit :uncache

  enum severity: [:silence, :reject]

  scope :recent, -> { reorder(id: :desc) }

  def self.silence?(object)
    (object.is_a?(Status) && (silence?(object.account) || object.media_attachments.any? { |attachment| silence? attachment })) ||
      [:description, :display_name, :name, :note, :spoiler_text, :text].any? do |key|
        object.respond_to?(key) && silenced_texts.any? do |text|
          object.public_send(key)&.include? text
        end
      end
  end

  def self.rejected_texts
    Rails.cache.fetch :rejected_texts do
      where(severity: :reject).pluck(:text)
    end
  end

  def self.silenced_texts
    Rails.cache.fetch :silenced_texts do
      where(severity: :silence).pluck(:text)
    end
  end

  private

  def uncache
    Rails.cache.delete :rejected_texts
    Rails.cache.delete :silenced_texts
  end
end

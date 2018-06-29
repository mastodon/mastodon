# frozen_string_literal: true
# == Schema Information
#
# Table name: custom_filters
#
#  id           :bigint(8)        not null, primary key
#  account_id   :bigint(8)
#  expired_at   :datetime
#  phrase       :text             default(""), not null
#  context      :string           default([]), not null, is an Array
#  irreversible :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class CustomFilter < ApplicationRecord
  belongs_to :account

  validates :phrase, :context, presence: true

  scope :active_irreversible, -> { where(irreversible: true).where(Arel.sql('expired_at IS NULL OR expired_at > NOW()')) }

  after_commit :remove_cache

  def expired?
    expired_at.present? && expired_at < Time.now.utc
  end

  def matches?(status, current_context)
    return if !context.include?(current_context.to_s) || expired?

    regex = Regexp.new(Regexp.escape(phrase), true)

    !regex.match(status.text).nil? ||
      (status.spoiler_text.present? && !regex.match(status.spoiler_text).nil?)
  end

  private

  def remove_cache
    Rails.cache.delete("filters:#{account_id}")
  end
end

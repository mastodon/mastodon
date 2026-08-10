# frozen_string_literal: true

# == Schema Information
#
# Table name: moderation_suggestions
#
#  id                         :bigint(8)        not null, primary key
#  action                     :integer          not null
#  state                      :integer          default("new"), not null
#  target_key                 :string           not null
#  target_type                :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  moderation_subscription_id :bigint(8)
#
class ModerationSuggestion < ApplicationRecord
  belongs_to :moderation_subscription

  enum :state, {
    new: 0,
    mailed: 1,
    applied: 2,
    dismissed: 3,
  }, prefix: :state

  enum :action, {
    retract: -1,
    accept: 0,
    reject: 1,
  }, suffix: :action

  enum :target_type, {
    domain: 0,
  }, suffix: :target_type

  before_validation :normalize_target_key

  private

  def normalize_target_key
    case target_type
    when :domain
      self.target_key = TagManager.instance.normalize_domain(target_key)
    end
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: subscribed_advisories
#
#  id                         :bigint(8)        not null, primary key
#  action                     :integer          not null
#  target_key                 :string           not null
#  target_type                :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  moderation_subscription_id :bigint(8)        not null
#

class SubscribedAdvisory < ApplicationRecord
  belongs_to :moderation_subscription, inverse_of: :advisories

  enum :action, {
    accept: 0,
    reject: 1,
    limit: 2,
  }, suffix: :action

  enum :target_type, {
    domain: 0,
  }, suffix: :target_type

  before_validation :normalize_target_key

  # TODO: handle subdomains
  scope :conflicting_advisories, lambda { |advisory|
    joins(:moderation_subscription)
      .where(
        target_type: advisory.target_type,
        target_key: advisory.target_key,
        moderation_subscription: { priority: ..advisory.moderation_subscription.priority }
      )
      .where.not(action: advisory.action)
      .where.not(moderation_subscription_id: advisory.moderation_subscription_id)
  }

  # TODO: handle subdomains?
  scope :superseding_advisories, lambda { |advisory|
    joins(:moderation_subscription)
      .where(
        target_type: advisory.target_type,
        target_key: advisory.target_key,
        action: advisory.action,
        moderation_subscription: { priority: ...advisory.moderation_subscription.priority }
      )
  }

  private

  def normalize_target_key
    case target_type
    when :domain
      self.target_key = TagManager.instance.normalize_domain(target_key)
    end
  end
end

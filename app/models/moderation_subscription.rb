# frozen_string_literal: true

# == Schema Information
#
# Table name: moderation_subscriptions
#
#  id                     :bigint(8)        not null, primary key
#  apply_automatically    :boolean          default(FALSE), not null
#  last_synced_at         :datetime
#  list_action            :integer
#  name                   :string
#  preserve_relationships :boolean          default(TRUE), not null
#  priority               :integer
#  retract_automatically  :boolean          default(TRUE), not null
#  type                   :integer          not null
#  url                    :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class ModerationSubscription < ApplicationRecord
  self.inheritance_column = nil

  PRIORITY_LIMIT = (2**31) - 1

  has_many :advisories, class_name: 'SubscribedAdvisory', inverse_of: :moderation_subscription, dependent: :delete_all
  has_many :suggestions, class_name: 'ModerationSuggestion', inverse_of: :moderation_subscription, dependent: :delete_all

  validates :name, presence: true
  validates :url, presence: true, url: true
  validates :priority, presence: true, numericality: { in: (-PRIORITY_LIMIT..PRIORITY_LIMIT) }

  enum :type, {
    csv_list: 0,
  }

  enum :list_action, {
    accept: 0,
    reject: 1,
  }, suffix: :action

  def to_log_human_identifier
    name
  end

  def apply_conditions
    if apply_automatically?
      preserve_relationships? ? :safely : :always
    else
      :never
    end
  end

  def apply_conditions=(conditions)
    case conditions.to_s
    when 'never'
      self.apply_automatically = false
    when 'always'
      self.apply_automatically = true
      self.preserve_relationships = false
    when 'safely'
      self.apply_automatically = true
      self.preserve_relationships = true
    else
      raise ArgumentError
    end
  end
end

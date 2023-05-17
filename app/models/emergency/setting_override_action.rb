# frozen_string_literal: true

# == Schema Information
#
# Table name: emergency_setting_override_actions
#
#  id                :bigint(8)        not null, primary key
#  emergency_rule_id :bigint(8)        not null
#  setting           :string           not null
#  value             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Emergency::SettingOverrideAction < ApplicationRecord
  belongs_to :emergency_rule, class_name: 'Emergency::Rule', inverse_of: :setting_override_actions

  # When multiple values are allowed, and rules define multiple overrides,
  # the first one in the allowed list takes precedence, e.g. if a rule
  # sets the registration mode to `approved` and another to `none`, and
  # both rules are active, the mode is switched to `none` because this is
  # the first value to appear in the list below.
  ALLOWED_SETTINGS = {
    'registrations_mode' => %w(none approved),
    'captcha_enabled' => %w(true),
  }.freeze

  validates :setting, presence: true, inclusion: { in: ALLOWED_SETTINGS.keys }

  after_commit :invalidate_cache!

  class << self
    def overridden_setting(key)
      return nil unless ALLOWED_SETTINGS.key?(key)

      candidates = Rails.cache.fetch("emergency_setting_override:#{key}") do
        where(setting: key).pluck(:emergency_rule_id, :value)
      end

      return nil if candidates.empty?

      rules_triggered_at = Emergency::Rule.triggered_at(candidates.map(&:first))

      values = candidates.map(&:second).zip(rules_triggered_at).filter_map { |value, triggered_at| value if triggered_at.present? }
      return nil if values.empty?

      ALLOWED_SETTINGS[key].first { |value| values.include?(value) }
    end
  end

  private

  def invalidate_cache!
    Rails.cache.delete("emergency_setting_override:#{setting}")
  end
end

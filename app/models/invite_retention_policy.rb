# frozen_string_literal: true

class InviteRetentionPolicy
  def self.current
    new
  end

  def invite_retention_period
    retention_period Setting.invite_retention_period
  end

  def invite_max_uses
    max_uses Setting.invite_max_uses
  end

  private

  def retention_period(value)
    value.days if value.is_a?(Integer) && value.positive?
  end

  def max_uses(value)
    value if value.is_a?(Integer) && value.positive?
  end
end

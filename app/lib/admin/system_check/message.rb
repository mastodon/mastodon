# frozen_string_literal: true

class Admin::SystemCheck::Message
  attr_reader :key, :value, :action, :critical

  def initialize(key, value = nil, action = nil, critical = false)
    @key      = key
    @value    = value
    @action   = action
    @critical = critical
  end

  def to_partial_path
    'admin/system_checks/message'
  end
end

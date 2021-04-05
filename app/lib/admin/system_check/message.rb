# frozen_string_literal: true

class Admin::SystemCheck::Message
  attr_reader :key, :value, :action

  def initialize(key, value = nil, action = nil)
    @key    = key
    @value  = value
    @action = action
  end
end

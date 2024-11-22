# frozen_string_literal: true

class Admin::SystemCheck::BaseCheck
  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
  end

  def skip?
    false
  end

  def pass?
    raise NotImplementedError
  end

  def message
    raise NotImplementedError
  end
end

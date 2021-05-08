# frozen_string_literal: true

class Admin::SystemCheck::BaseCheck
  def pass?
    raise NotImplementedError
  end

  def message
    raise NotImplementedError
  end
end

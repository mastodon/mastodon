# frozen_string_literal: true

module FrameworkConfigurationHelpers
  def with_forgery_protection
    ActionController::Base.allow_forgery_protection.tap do |original|
      ActionController::Base.allow_forgery_protection = true
      yield
      ActionController::Base.allow_forgery_protection = original
    end
  end
end

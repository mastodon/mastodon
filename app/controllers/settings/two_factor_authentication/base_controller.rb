# frozen_string_literal: true

module Settings
  module TwoFactorAuthentication
    class BaseController < ::Settings::BaseController
      layout -> { truthy_param?(:oauth) ? 'modal' : 'admin' }
    end
  end
end

# frozen_string_literal: true

module CurrentRequest
  extend ActiveSupport::Concern

  included do
    before_action do
      Current.ip_address = request.ip
      Current.user_agent = request.user_agent
    end
  end
end

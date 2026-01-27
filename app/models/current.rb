# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :ip_address, :user_agent
end

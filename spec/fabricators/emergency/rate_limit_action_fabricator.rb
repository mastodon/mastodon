# frozen_string_literal: true

Fabricator('Emergency::RateLimitAction') do
  emergency_rule { Fabricate('Emergency::Rule') }
  new_users_only false
end

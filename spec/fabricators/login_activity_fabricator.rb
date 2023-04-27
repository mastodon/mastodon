# frozen_string_literal: true

Fabricator(:login_activity) do
  user
  authentication_method 'password'
  success               true
  failure_reason        nil
  ip                    { Faker::Internet.ip_v4_address }
  user_agent            { Faker::Internet.user_agent }
end

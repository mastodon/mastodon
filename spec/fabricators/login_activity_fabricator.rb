# frozen_string_literal: true

Fabricator(:login_activity) do
  user { Fabricate.build(:user) }
  authentication_method 'password'
  success               true
  failure_reason        nil
  ip                    { '192.168.1.1' }
  user_agent            { 'Mozilla 1.0' }
end

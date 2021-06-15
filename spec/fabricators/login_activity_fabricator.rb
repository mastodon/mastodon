Fabricator(:login_activity) do
  user
  strategy       'password'
  success        true
  failure_reason nil
  ip             { Faker::Internet.ip_v4_address }
  user_agent     { Faker::Internet.user_agent }
end

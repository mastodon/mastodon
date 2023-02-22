# frozen_string_literal: true

Fabricator(:user_invite_request) do
  user
  text { Faker::Lorem.sentence }
end

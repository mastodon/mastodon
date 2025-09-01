# frozen_string_literal: true

Fabricator(:username_block) do
  username { sequence(:email) { |i| "#{i}#{Faker::Internet.username}" } }
  exact false
  allow_with_approval false
end

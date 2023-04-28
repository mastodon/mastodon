# frozen_string_literal: true

Fabricator(:user) do
  account      { Fabricate.build(:account, user: nil) }
  email        { sequence(:email) { |i| "#{i}#{Faker::Internet.email}" } }
  password     { Faker::Internet.password(min_length: 12) }
  confirmed_at { Time.zone.now }
  current_sign_in_at { Time.zone.now }
  agreement true
end

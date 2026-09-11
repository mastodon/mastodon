# frozen_string_literal: true

Fabricator(:email_subscription) do
  account
  email { sequence(:email) { |i| "#{i}#{Faker::Internet.email}" } }
  locale 'en'
end

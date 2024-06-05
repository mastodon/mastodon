# frozen_string_literal: true

Fabricator(:user) do
  account do |attrs|
    Fabricate.build(
      :account,
      attrs.fetch(:account_attributes, {}).merge(user: nil)
    )
  end
  email        { sequence(:email) { |i| "#{i}#{Faker::Internet.email}" } }
  password     '123456789'
  confirmed_at { Time.zone.now }
  current_sign_in_at { Time.zone.now }
  agreement true
end

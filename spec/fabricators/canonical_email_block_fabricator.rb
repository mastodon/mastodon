# frozen_string_literal: true

Fabricator(:canonical_email_block) do
  email { sequence(:email) { |i| "#{i}#{Faker::Internet.email}" } }
  reference_account { Fabricate(:account) }
end

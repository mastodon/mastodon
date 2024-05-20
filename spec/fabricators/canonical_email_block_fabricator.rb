# frozen_string_literal: true

Fabricator(:canonical_email_block) do
  email { |attrs| attrs[:reference_account] ? attrs[:reference_account].user_email : sequence(:email) { |i| "#{i}#{Faker::Internet.email}" } }
  reference_account { Fabricate.build(:account) }
end

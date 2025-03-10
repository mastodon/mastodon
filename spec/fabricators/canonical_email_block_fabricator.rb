# frozen_string_literal: true

Fabricator(:canonical_email_block) do
  email { sequence(:email) { |i| "email_#{i}@host.example" } }
  reference_account { Fabricate.build(:account) }
end

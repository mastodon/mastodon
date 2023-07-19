# frozen_string_literal: true

Fabricator(:account_warning) do
  account { Fabricate.build(:account) }
  target_account(fabricator: :account)
  text { Faker::Lorem.paragraph }
  action 'suspend'
end

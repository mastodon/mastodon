# frozen_string_literal: true

Fabricator(:account_warning) do
  account { Fabricate.build(:account) }
  target_account(fabricator: :account)
  text { 'Account warning text' }
  action 'suspend'
end

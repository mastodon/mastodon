# frozen_string_literal: true

Fabricator(:account_pin) do
  account
  target_account(fabricator: :account)
  before_create { |account_pin, _| account_pin.account.follow!(account_pin.target_account) }
end

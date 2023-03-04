# frozen_string_literal: true

Fabricator(:list_account) do
  list
  account
  before_create { |list_account, _| list_account.list.account.follow!(account) }
end

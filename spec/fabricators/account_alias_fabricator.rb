# frozen_string_literal: true

Fabricator(:account_alias) do
  account
  acct 'test@example.com'
  uri 'https://example.com/users/test'
end

Fabricator(:account_migration) do
  account
  target_account
  followers_count 1234
  acct 'test@example.com'
end
